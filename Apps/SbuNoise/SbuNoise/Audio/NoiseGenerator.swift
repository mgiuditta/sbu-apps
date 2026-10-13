/// Produces one colored-noise sample at a time, without allocating: safe on the render thread.
///
/// White is a 64-bit xorshift mapped to [-1, 1]. Pink is Paul Kellet's refined filter
/// (±0.05 dB above 9.2 Hz at 44.1 kHz). Brown is a leaky integrator of white. Blue and violet are
/// the first difference of pink and white. Each color has its own gain, so switching color keeps
/// the loudness (RMS) about the same.
nonisolated struct NoiseGenerator: Sendable {
    let color: NoiseColor
    private var state: UInt64
    private var pink: (Float, Float, Float, Float, Float, Float, Float) = (0, 0, 0, 0, 0, 0, 0)
    private var brown: Float = 0
    private var previous: Float = 0

    /// - Parameter seed: Any non-zero value; two generators with different seeds are independent.
    init(color: NoiseColor, seed: UInt64 = 0x9E37_79B9_7F4A_7C15) {
        self.color = color
        state = seed == 0 ? 1 : seed
    }

    /// The next sample: about 0.18 RMS for every color, always within [-1, 1].
    mutating func next() -> Float {
        let sample: Float
        switch color {
        case .white:
            sample = white() * 0.312
        case .pink:
            sample = nextPink() * 0.104
        case .brown:
            let w = white()
            brown = (brown + 0.02 * w) / 1.02
            sample = brown * 3.14
        case .blue:
            let p = nextPink()
            sample = (p - previous) * 0.172
            previous = p
        case .violet:
            let w = white()
            sample = (w - previous) * 0.22
            previous = w
        }
        return min(max(sample, -1), 1)
    }

    private mutating func white() -> Float {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        // The top 24 bits fill a Float's mantissa exactly.
        return Float(state >> 40) / Float(1 << 23) - 1
    }

    private mutating func nextPink() -> Float {
        let w = white()
        pink.0 = 0.99886 * pink.0 + w * 0.0555179
        pink.1 = 0.99332 * pink.1 + w * 0.0750759
        pink.2 = 0.96900 * pink.2 + w * 0.1538520
        pink.3 = 0.86650 * pink.3 + w * 0.3104856
        pink.4 = 0.55000 * pink.4 + w * 0.5329522
        pink.5 = -0.7616 * pink.5 - w * 0.0168980
        let sum = pink.0 + pink.1 + pink.2 + pink.3 + pink.4 + pink.5 + pink.6 + w * 0.5362
        pink.6 = w * 0.115926
        return sum
    }
}
