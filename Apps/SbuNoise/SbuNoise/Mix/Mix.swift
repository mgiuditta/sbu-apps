import Foundation

/// Up to five sounds that play together, each with its own position, volume and pitch, saved with a name.
nonisolated struct Mix: Codable, Hashable, Identifiable, Sendable {
    static let maxLayers = 5

    var id = UUID()
    var name: String
    var layers: [MixLayer]

    /// A new mix with the sounds spread evenly around the listener, the first one in front.
    init(id: UUID = UUID(), name: String, soundIDs: [String]) {
        self.id = id
        self.name = name
        layers = soundIDs.prefix(Self.maxLayers).enumerated().map { index, soundID in
            MixLayer(soundID: soundID, position: Self.spread(index, of: min(soundIDs.count, Self.maxLayers)))
        }
    }

    var isFull: Bool { layers.count >= Self.maxLayers }

    /// Adds a sound in the first free place on the ring, if there is room.
    mutating func add(_ soundID: String) {
        guard !isFull else { return }
        layers.append(MixLayer(soundID: soundID, position: Self.spread(layers.count, of: Self.maxLayers)))
    }

    /// Place `index` of `count` on a ring halfway to the edge, clockwise from the front.
    static func spread(_ index: Int, of count: Int) -> MixPoint {
        let angle = 2 * Double.pi * Double(index) / Double(max(count, 1))
        return MixPoint(x: 0.5 * sin(angle), y: -0.5 * cos(angle))
    }
}
