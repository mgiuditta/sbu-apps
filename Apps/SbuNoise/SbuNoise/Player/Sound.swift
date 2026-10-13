import Foundation

/// One entry of the catalog the player swipes through.
nonisolated struct Sound: Identifiable, Hashable, Sendable {
    /// Stable across versions: favorites, mixes and the last sound refer to it.
    let id: String
    let name: LocalizedStringResource
    let systemImage: String
    let category: SoundCategory
    let source: SoundSource

    static func == (lhs: Sound, rhs: Sound) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    /// The five noises generated in code, first in the catalog.
    static let generated = [
        Sound(id: "noise.white", name: "Rumore bianco", systemImage: "waveform", category: .noise, source: .generated(.white)),
        Sound(id: "noise.pink", name: "Rumore rosa", systemImage: "waveform.path", category: .noise, source: .generated(.pink)),
        Sound(id: "noise.brown", name: "Rumore marrone", systemImage: "aqi.low", category: .noise, source: .generated(.brown)),
        Sound(id: "noise.blue", name: "Rumore blu", systemImage: "aqi.medium", category: .noise, source: .generated(.blue)),
        Sound(id: "noise.violet", name: "Rumore viola", systemImage: "sparkles", category: .noise, source: .generated(.violet)),
    ]
}
