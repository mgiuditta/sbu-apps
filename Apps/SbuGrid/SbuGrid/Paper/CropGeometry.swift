import CoreGraphics

/// The crop of the photo: a rectangle in unit coordinates (0…1 across and down the photo),
/// optionally held to the shape of a sheet. Pure, so the handles, VoiceOver's actions and the
/// stored crop all obey the same rules: never outside the photo, never smaller than a twentieth
/// of its shorter side, always the sheet's shape when there is a sheet.
nonisolated enum CropGeometry {
    /// The smallest crop side, as a fraction of the photo's shorter side.
    static let minimumFraction: CGFloat = 0.05
    static let whole = CGRect(x: 0, y: 0, width: 1, height: 1)

    /// The largest crop of `aspect` (width over height, in pixels) centred on the photo; the
    /// whole photo when `aspect` is `nil`.
    static func fitted(aspect: Double?, imageSize: CGSize) -> CGRect {
        guard let aspect, aspect.isFinite, aspect > 0, isValid(imageSize) else { return whole }
        let imageAspect = imageSize.width / imageSize.height
        if CGFloat(aspect) < imageAspect {
            let width = CGFloat(aspect) / imageAspect
            return CGRect(x: (1 - width) / 2, y: 0, width: width, height: 1)
        } else {
            let height = imageAspect / CGFloat(aspect)
            return CGRect(x: 0, y: (1 - height) / 2, width: 1, height: height)
        }
    }

    /// `rect` moved by `delta` (unit coordinates), stopped at the photo's edges.
    static func moved(_ rect: CGRect, by delta: CGSize) -> CGRect {
        guard delta.width.isFinite, delta.height.isFinite else { return rect }
        var moved = rect.offsetBy(dx: delta.width, dy: delta.height)
        moved.origin.x = min(max(moved.minX, 0), 1 - rect.width)
        moved.origin.y = min(max(moved.minY, 0), 1 - rect.height)
        return moved
    }

    /// `rect` with `corner` dragged to `point` (unit coordinates) and the opposite corner still,
    /// held to `aspect` when given, inside the photo and not smaller than the minimum.
    static func dragged(_ rect: CGRect, corner: CropCorner, to point: CGPoint, aspect: Double?, imageSize: CGSize) -> CGRect {
        guard isValid(imageSize), point.x.isFinite, point.y.isFinite else { return rect }
        let anchor = scaled(corner.opposite.point(in: rect), by: imageSize)
        let target = scaled(CGPoint(x: min(max(point.x, 0), 1), y: min(max(point.y, 0), 1)), by: imageSize)
        // Room from the still corner towards the dragged one, in pixels.
        let room = CGSize(
            width: corner.isLeft ? anchor.x : imageSize.width - anchor.x,
            height: corner.isTop ? anchor.y : imageSize.height - anchor.y
        )
        let minimum = min(imageSize.width, imageSize.height) * minimumFraction
        var width = corner.isLeft ? anchor.x - target.x : target.x - anchor.x
        var height = corner.isTop ? anchor.y - target.y : target.y - anchor.y
        width = max(width, minimum)
        height = max(height, minimum)

        if let aspect, aspect.isFinite, aspect > 0 {
            let ratio = CGFloat(aspect)
            // Follow the finger along the side it moved more, then fit the room.
            if width / height > ratio {
                height = width / ratio
            } else {
                width = height * ratio
            }
            let fit = min(1, room.width / width, room.height / height)
            width *= fit
            height *= fit
        } else {
            width = min(width, room.width)
            height = min(height, room.height)
        }

        let origin = CGPoint(x: corner.isLeft ? anchor.x - width : anchor.x, y: corner.isTop ? anchor.y - height : anchor.y)
        return CGRect(
            x: origin.x / imageSize.width,
            y: origin.y / imageSize.height,
            width: width / imageSize.width,
            height: height / imageSize.height
        )
    }

    /// `rect` grown or shrunk by `factor` around its centre, as VoiceOver's actions do, held to
    /// `aspect`, inside the photo and not smaller than the minimum.
    static func scaled(_ rect: CGRect, by factor: CGFloat, aspect: Double?, imageSize: CGSize) -> CGRect {
        guard factor.isFinite, factor > 0, isValid(imageSize) else { return rect }
        let minimum = min(imageSize.width, imageSize.height) * minimumFraction
        var width = rect.width * imageSize.width * factor
        var height = rect.height * imageSize.height * factor
        let grow = max(1, minimum / width, minimum / height)
        width *= grow
        height *= grow
        let shrink = min(1, imageSize.width / width, imageSize.height / height)
        width *= shrink
        height *= shrink
        if let aspect, aspect.isFinite, aspect > 0 {
            // Rounding may have nudged the shape: the height follows the width.
            height = min(width / CGFloat(aspect), imageSize.height)
            width = height * CGFloat(aspect)
        }
        let unit = CGSize(width: width / imageSize.width, height: height / imageSize.height)
        let centred = CGRect(x: rect.midX - unit.width / 2, y: rect.midY - unit.height / 2, width: unit.width, height: unit.height)
        return moved(centred, by: .zero)
    }

    /// The crop in whole pixels of the photo, never empty and never outside it.
    static func pixelRect(_ rect: CGRect, imageSize: CGSize) -> CGRect {
        guard isValid(imageSize) else { return .zero }
        let bounds = CGRect(origin: .zero, size: imageSize)
        let unit = sanitized(rect) ?? whole
        let pixels = CGRect(
            x: unit.minX * imageSize.width,
            y: unit.minY * imageSize.height,
            width: unit.width * imageSize.width,
            height: unit.height * imageSize.height
        ).integral.intersection(bounds)
        return pixels.width >= 1 && pixels.height >= 1 ? pixels : bounds
    }

    /// A stored crop if it still makes sense, `nil` otherwise: not a number, empty or outside the photo.
    static func sanitized(_ rect: CGRect) -> CGRect? {
        // The raw size: `width` and `height` would turn a negative size positive.
        let values = [rect.origin.x, rect.origin.y, rect.size.width, rect.size.height]
        guard values.allSatisfy(\.isFinite), rect.size.width > 0, rect.size.height > 0,
              rect.minX >= -0.0001, rect.minY >= -0.0001, rect.maxX <= 1.0001, rect.maxY <= 1.0001
        else { return nil }
        return rect.intersection(whole)
    }

    private static func isValid(_ size: CGSize) -> Bool {
        size.width.isFinite && size.height.isFinite && size.width > 0 && size.height > 0
    }

    private static func scaled(_ point: CGPoint, by size: CGSize) -> CGPoint {
        CGPoint(x: point.x * size.width, y: point.y * size.height)
    }
}
