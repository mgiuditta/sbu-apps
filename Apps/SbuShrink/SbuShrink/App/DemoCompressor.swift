import Foundation

/// A compressor that writes nothing: it walks the progress in `duration` and "makes" a copy of
/// the planned size. Names marked broken fail halfway, like a real encoder error.
nonisolated struct DemoCompressor: VideoCompressor {
    var duration: Duration = .milliseconds(600)

    func compress(_ input: URL, plan: CompressionPlan, to output: URL, progress: @escaping @Sendable (Double) -> Void) async throws -> Int64 {
        // A step a second when slow: the figure then rests between steps, so a screenshot never
        // catches its digits mid-transition.
        let steps = duration >= .seconds(2) ? Int(duration.components.seconds) : 20
        for step in 1...steps {
            do {
                try await Task.sleep(for: duration / steps)
            } catch {
                throw CompressionError.cancelled
            }
            if step == steps / 2, input.lastPathComponent.contains(DemoVideos.brokenMarker) {
                throw CompressionError.encodingFailed
            }
            progress(Double(step) / Double(steps))
        }
        // The planned size, or the source's when the plan cannot save anything.
        return max(plan.estimatedBytes, 1)
    }
}
