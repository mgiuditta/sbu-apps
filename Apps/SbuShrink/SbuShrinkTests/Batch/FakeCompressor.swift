import Foundation
import os
@testable import SbuShrink

/// A compressor that does what each file name tells it to, and records the plans it was given.
nonisolated final class FakeCompressor: VideoCompressor {
    enum Behavior: Sendable {
        /// Reports 25%, 50%, 100% and returns this size.
        case succeed(Int64)
        /// Returns the planned size.
        case planned
        /// Fails like an encoder error.
        case fail
        /// Waits until cancelled.
        case hang
    }

    private let behaviors: [String: Behavior]
    private let plans = OSAllocatedUnfairLock<[String: CompressionPlan]>(initialState: [:])

    init(_ behaviors: [String: Behavior] = [:]) {
        self.behaviors = behaviors
    }

    /// The plan each file was compressed with, by name.
    var receivedPlans: [String: CompressionPlan] { plans.withLock { $0 } }

    func compress(_ input: URL, plan: CompressionPlan, to output: URL, progress: @escaping @Sendable (Double) -> Void) async throws -> Int64 {
        let name = input.lastPathComponent
        plans.withLock { $0[name] = plan }
        switch behaviors[name] ?? .planned {
        case .succeed(let bytes):
            for step in [0.25, 0.5, 1] {
                progress(step)
                await Task.yield()
            }
            return bytes
        case .planned:
            progress(1)
            return plan.estimatedBytes
        case .fail:
            progress(0.3)
            throw CompressionError.encodingFailed
        case .hang:
            progress(0.1)
            do {
                try await Task.sleep(for: .seconds(60))
            } catch {
                throw CompressionError.cancelled
            }
            return 0
        }
    }
}
