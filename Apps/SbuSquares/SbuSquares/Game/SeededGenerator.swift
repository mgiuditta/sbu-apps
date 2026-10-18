/// SplitMix64: the same seed gives the same pieces on every device and every version.
///
/// The system generator cannot be seeded, and the Partita del giorno must be the same for everyone.
nonisolated struct SeededGenerator: RandomNumberGenerator, Codable, Hashable, Sendable {
    private(set) var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
