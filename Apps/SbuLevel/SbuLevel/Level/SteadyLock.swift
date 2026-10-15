/// The settings of the steady lock: after Blocca, the reading freezes only once it holds still.
nonisolated enum SteadyLock {
    /// About two seconds of samples at the motion rate.
    static let sampleCount = 60
    /// The tolerances offered, in degrees either way, as in Clinometer.
    static let toleranceRange = 0.1...3.0
    static let toleranceStep = 0.1
    static let defaultTolerance = 0.5

    /// `tolerance` inside the range, to the step, so a saved value from anywhere reads sensibly.
    static func clamped(_ tolerance: Double) -> Double {
        // Dividing by the steps per degree, not multiplying by the step, keeps 1,2 exactly 1,2.
        let stepped = (tolerance / toleranceStep).rounded() / (1 / toleranceStep).rounded()
        return min(toleranceRange.upperBound, max(toleranceRange.lowerBound, stepped))
    }

    /// A sampler that waits for two seconds within `tolerance`.
    static func sampler(tolerance: Double) -> StableSampler {
        StableSampler(sampleCount: sampleCount, tolerance: clamped(tolerance))
    }
}
