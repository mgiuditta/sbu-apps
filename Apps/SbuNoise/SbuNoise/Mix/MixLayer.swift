import Foundation

/// One sound of a mix, with where it sits around the listener and how it plays.
nonisolated struct MixLayer: Codable, Hashable, Identifiable, Sendable {
    var id = UUID()
    /// A `Sound.id`; a sound that no longer exists is skipped.
    var soundID: String
    var position: MixPoint
    /// 0...1, before the distance from the listener.
    var volume = 1.0
    /// In cents, -1200...1200: one octave down or up.
    var pitch = 0.0
    /// 0...1 of the pad radius: how far the sound wanders around its position.
    var variance = 0.0
    /// 0...1: how fast it wanders.
    var speed = 0.5

    /// Back to full volume, normal pitch, no variance and normal speed, as in the original; the
    /// position stays.
    func reset() -> MixLayer {
        MixLayer(id: id, soundID: soundID, position: position)
    }
}
