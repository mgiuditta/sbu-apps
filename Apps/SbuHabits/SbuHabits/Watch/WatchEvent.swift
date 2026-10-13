/// What arrives from the other side of WatchConnectivity, decoded, in the order it arrived.
nonisolated enum WatchEvent: Equatable, Sendable {
    /// The session is ready, or the paired watch changed: send the grid again.
    case activated
    /// A grid from the iPhone, on the watch.
    case snapshot(WatchSnapshot)
    /// A tap from the watch, on the iPhone.
    case action(WatchAction)
    /// The watch asks for today's grid, on the iPhone.
    case refreshRequest
}
