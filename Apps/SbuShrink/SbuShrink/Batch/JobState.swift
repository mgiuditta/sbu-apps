/// Where one video of the batch is.
nonisolated enum JobState: Equatable, Sendable {
    /// Its file is being copied and read.
    case loading
    /// Not a video the iPhone can read: it stays out of the batch.
    case unreadable
    /// Ready, in the queue.
    case waiting
    /// Being written, 0 to 1.
    case compressing(Double)
    /// Compressed to `bytes`; `saved` when the copy went to Photos.
    case done(bytes: Int64, saved: Bool)
    /// The copy would weigh as much as the original: the original stays as it is.
    case notSmaller
    /// The encoder stopped on this one; the queue went on.
    case failed
    /// Stopped with Annulla before or while it was compressing.
    case cancelled

    /// Whether the run has nothing more to do on it.
    var isFinished: Bool {
        switch self {
        case .done, .notSmaller, .failed, .cancelled, .unreadable: true
        case .loading, .waiting, .compressing: false
        }
    }

    /// How far the run is on it, 0 to 1.
    var fraction: Double {
        switch self {
        case .compressing(let value): value.isFinite ? value.clamped(to: 0...1) : 0
        case .done, .notSmaller, .failed, .cancelled: 1
        case .loading, .unreadable, .waiting: 0
        }
    }
}
