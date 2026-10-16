import CoreGraphics

/// The largest size of a given shape that fits in a box.
nonisolated enum AspectFit {
    /// `aspect` scaled to fit `container`; zero when either has no area or is not a number.
    static func size(of aspect: CGSize, in container: CGSize) -> CGSize {
        guard aspect.width.isFinite, aspect.height.isFinite, container.width.isFinite, container.height.isFinite,
              aspect.width > 0, aspect.height > 0, container.width > 0, container.height > 0
        else { return .zero }
        let scale = min(container.width / aspect.width, container.height / aspect.height)
        return CGSize(width: aspect.width * scale, height: aspect.height * scale)
    }
}
