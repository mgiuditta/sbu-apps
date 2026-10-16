import Foundation

/// Writes the compressed copy of one video.
nonisolated protocol VideoCompressor: Sendable {
    /// Compresses `input` to `output` following `plan`.
    /// - Parameter progress: Called with 0 to 1 as the copy is written, from any thread.
    /// - Throws: `CompressionError`; `.cancelled` when the task is cancelled, and then no file is left at `output`.
    func compress(_ input: URL, plan: CompressionPlan, to output: URL, progress: @escaping @Sendable (Double) -> Void) async throws
}
