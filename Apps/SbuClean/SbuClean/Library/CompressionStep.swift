/// Where a compression is.
nonisolated enum CompressionStep: Equatable, Sendable {
    /// Downloading the original from iCloud, 0 to 1.
    case downloading(Double)
    /// Writing the compressed copy, 0 to 1.
    case compressing(Double)
}
