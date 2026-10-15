/// Collects gravity samples while the iPhone holds still and averages them, starting over if it moves.
/// By default about one second within 0,3°, for a calibration; the steady lock waits longer, within
/// the tolerance the user chooses.
nonisolated struct StableSampler: Equatable, Sendable {
    /// One second of samples at the motion rate.
    static let sampleCount = 30
    /// How far, in degrees, a sample may stray from the first one before the capture starts over.
    static let tolerance = 0.3

    enum Outcome: Equatable, Sendable {
        /// Still collecting; `progress` is in 0..<1.
        case collecting(progress: Double)
        /// The iPhone moved: collecting started over from this sample.
        case moved
        /// Enough steady samples: their average.
        case stable(Gravity)
    }

    /// Steady samples needed.
    let sampleCount: Int
    /// Degrees a sample may stray from the first one.
    let tolerance: Double
    private(set) var samples: [Gravity] = []

    init(sampleCount: Int = Self.sampleCount, tolerance: Double = Self.tolerance) {
        self.sampleCount = sampleCount
        self.tolerance = tolerance
    }

    mutating func add(_ sample: Gravity) -> Outcome {
        if let first = samples.first, sample.angle(to: first) > tolerance {
            samples = [sample]
            return .moved
        }
        samples.append(sample)
        if samples.count >= sampleCount, let mean = Gravity.mean(of: samples) {
            return .stable(mean)
        }
        return .collecting(progress: Double(samples.count) / Double(sampleCount))
    }
}
