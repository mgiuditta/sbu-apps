import CoreGraphics

/// What the running camera can do, for the torch and zoom controls.
nonisolated struct CameraInfo: Equatable, Sendable {
    var hasTorch: Bool
    /// The widest zoom offered, as the user counts it (1× is the main lens).
    var maxZoom: CGFloat
}
