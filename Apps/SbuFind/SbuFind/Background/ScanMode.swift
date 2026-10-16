/// How the scanner listens.
nonisolated enum ScanMode: Equatable, Sendable {
    /// The app is open: every device, every advertisement, for the list and the finder.
    case foreground
    /// The app is in the background: only devices advertising these services, as iOS allows.
    /// iOS reports each device far less often, and only while the app has not been force-quit.
    case background(services: [String])
    /// The app is in the background with nothing that needs listening.
    case paused
}
