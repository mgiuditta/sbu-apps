/// The five noises generated in code, by how their energy falls or rises per octave.
nonisolated enum NoiseColor: String, CaseIterable, Sendable {
    /// Flat spectrum, 0 dB per octave.
    case white
    /// −3 dB per octave (1/f).
    case pink
    /// −6 dB per octave (1/f²).
    case brown
    /// +3 dB per octave.
    case blue
    /// +6 dB per octave.
    case violet
}
