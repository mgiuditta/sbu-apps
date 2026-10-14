/// Where the camera stands, for the tool screen.
nonisolated enum CameraState: Equatable, Sendable {
    /// Before asking or starting.
    case idle
    case running
    /// Camera access denied or restricted: the screen explains and offers Settings and photos.
    case denied
    /// No camera (the simulator) or it failed to start.
    case unavailable
}
