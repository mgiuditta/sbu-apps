/// Collects about one second of gravity samples and averages them, starting over if the iPhone moves.
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

    private(set) var samples: [Gravity] = []

    mutating func add(_ sample: Gravity) -> Outcome {
        if let first = samples.first, sample.angle(to: first) > Self.tolerance {
            samples = [sample]
            return .moved
        }
        samples.append(sample)
        if samples.count >= Self.sampleCount, let mean = Gravity.mean(of: samples) {
            return .stable(mean)
        }
        return .collecting(progress: Double(samples.count) / Double(Self.sampleCount))
    }
}
