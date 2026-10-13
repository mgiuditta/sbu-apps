import Foundation

/// One entry of the catalog the player swipes through.
nonisolated struct Sound: Identifiable, Sendable {
    /// Stable across versions: favorites, mixes and the last sound refer to it.
    let id: String
    let name: LocalizedStringResource
    let systemImage: String
    let noise: NoiseColor

    /// The noises generated in code. ponytail: the catalog with recordings and categories replaces this list.
    static let generated = [
        Sound(id: "noise.white", name: "Rumore bianco", systemImage: "waveform", noise: .white),
        Sound(id: "noise.pink", name: "Rumore rosa", systemImage: "waveform.path", noise: .pink),
        Sound(id: "noise.brown", name: "Rumore marrone", systemImage: "water.waves", noise: .brown),
        Sound(id: "noise.blue", name: "Rumore blu", systemImage: "wind", noise: .blue),
        Sound(id: "noise.violet", name: "Rumore viola", systemImage: "sparkles", noise: .violet),
    ]
}
