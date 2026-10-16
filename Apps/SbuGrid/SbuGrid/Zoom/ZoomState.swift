import CoreGraphics

/// How far the photo is zoomed in and moved, on a view of a given size.
///
/// The photo never gets smaller than the view and never leaves an edge of paper showing: the
/// offset is kept within what the zoom adds on each side.
nonisolated struct ZoomState: Equatable, Sendable {
    static let scaleRange: ClosedRange<CGFloat> = 1...8
    /// One step of the VoiceOver zoom action, and of a double tap.
    static let step: CGFloat = 2

    private(set) var scale: CGFloat = 1
    private(set) var offset: CGSize = .zero

    static let identity = ZoomState()

    var isZoomed: Bool { scale > Self.scaleRange.lowerBound }

    /// The zoom multiplied by `factor` around the centre, the offset kept inside the view.
    func zoomed(by factor: CGFloat, in size: CGSize) -> ZoomState {
        guard factor.isFinite, factor > 0 else { return self }
        var next = self
        next.scale = min(max(scale * factor, Self.scaleRange.lowerBound), Self.scaleRange.upperBound)
        // The offset grows with the zoom, so the point at the centre stays at the centre.
        let ratio = next.scale / scale
        next.offset = CGSize(width: offset.width * ratio, height: offset.height * ratio)
        return next.clamped(in: size)
    }

    /// The photo moved by `translation`, never past its edges.
    func panned(by translation: CGSize, in size: CGSize) -> ZoomState {
        guard translation.width.isFinite, translation.height.isFinite else { return self }
        var next = self
        next.offset = CGSize(width: offset.width + translation.width, height: offset.height + translation.height)
        return next.clamped(in: size)
    }

    /// The largest offset on each side at this zoom.
    func maximumOffset(in size: CGSize) -> CGSize {
        guard size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 else { return .zero }
        return CGSize(width: size.width * (scale - 1) / 2, height: size.height * (scale - 1) / 2)
    }

    private func clamped(in size: CGSize) -> ZoomState {
        let limit = maximumOffset(in: size)
        var next = self
        next.offset = CGSize(
            width: min(max(offset.width, -limit.width), limit.width),
            height: min(max(offset.height, -limit.height), limit.height)
        )
        return next
    }
}
