import Testing
@testable import SbuNoise

struct NoiseGeneratorTests {
    private static let count = 200_000

    private func samples(_ color: NoiseColor, seed: UInt64 = 42) -> [Float] {
        var generator = NoiseGenerator(color: color, seed: seed)
        return (0..<Self.count).map { _ in generator.next() }
    }

    /// The RMS that puts each color at −18 LUFS at the output, like the loops (EBU R128 meter on the
    /// same filters, plus the mixer's 1.2 dB): the redder colors need more RMS to sound as loud.
    @Test(arguments: [
        (NoiseColor.white, Float(0.072)),
        (.pink, 0.108),
        (.brown, 0.1252),
        (.blue, 0.0703),
        (.violet, 0.0702),
    ] as [(NoiseColor, Float)])
    func everyColorHasTheSameLoudnessAndNoClipping(_ color: NoiseColor, rms expected: Float) {
        let x = samples(color)
        let mean = x.reduce(0, +) / Float(x.count)
        let rms = (x.reduce(0) { $0 + $1 * $1 } / Float(x.count)).squareRoot()
        #expect(abs(mean) < 0.02)
        #expect(abs(rms - expected) / expected < 0.08)
        #expect(x.allSatisfy { (-1...1).contains($0) })
    }

    /// Lag-1 autocorrelation tells the colors apart: the redder, the smoother (closer to 1);
    /// the bluer, the more each sample swings against the last (towards −0.5).
    @Test(arguments: [
        (NoiseColor.white, -0.05...0.05),
        (.pink, 0.7...0.9),
        (.brown, 0.95...1),
        (.blue, -0.35 ... -0.15),
        (.violet, -0.55 ... -0.45),
    ] as [(NoiseColor, ClosedRange<Float>)])
    func spectrumTiltMatchesTheColor(_ color: NoiseColor, expected: ClosedRange<Float>) {
        let x = samples(color)
        let mean = x.reduce(0, +) / Float(x.count)
        var numerator: Float = 0
        var denominator: Float = 0
        for i in x.indices {
            let d = x[i] - mean
            denominator += d * d
            if i > 0 { numerator += d * (x[i - 1] - mean) }
        }
        #expect(expected.contains(numerator / denominator))
    }

    @Test func differentSeedsGiveIndependentNoise() {
        #expect(samples(.white, seed: 1).prefix(100) != samples(.white, seed: 2).prefix(100))
    }
}
