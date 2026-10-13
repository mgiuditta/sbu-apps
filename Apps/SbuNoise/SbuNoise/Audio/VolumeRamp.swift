import Foundation

/// A volume change over time, for fades in and out.
nonisolated struct VolumeRamp: Sendable, Equatable {
    let from: Float
    let to: Float
    let duration: Duration

    /// The volume `elapsed` after the ramp starts: `from` before it, `to` after it.
    ///
    /// Linear in gain. ponytail: an equal-power curve if a linear fade sounds uneven by ear.
    func volume(after elapsed: Duration) -> Float {
        guard duration > .zero else { return to }
        let progress = min(max(elapsed / duration, 0), 1)
        return from + (to - from) * Float(progress)
    }
}
