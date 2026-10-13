/// Where the duplicate and similar scan is.
nonisolated enum ScanState: Equatable, Sendable {
    /// Not started in this session.
    case idle
    /// Analysing photos: `done` of `total` new ones.
    case running(done: Int, total: Int)
    /// Stopped by the user: what was analysed is kept for next time.
    case cancelled
    /// Every photo analysed and grouped.
    case finished

    var isRunning: Bool {
        if case .running = self { true } else { false }
    }
}
