/// Why a video did not compress.
nonisolated enum CompressionError: Error, Equatable, Sendable {
    /// No video track, no length, or a format the iPhone cannot read.
    case unreadable
    /// The encoder stopped halfway.
    case encodingFailed
    /// The user stopped it.
    case cancelled
}
