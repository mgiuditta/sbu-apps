/// The screen the batch is on, in the original's order.
nonisolated enum Stage: Equatable, Sendable {
    /// Pick videos from Photos or Files.
    case picking
    /// Frame rate, dimensions, quality, the estimate and Comprimi.
    case settings
    /// The run: overall percentage, "video N di M", a row per video, Annulla.
    case compressing
    /// Before, after, savings, and what to do with the originals.
    case done
}
