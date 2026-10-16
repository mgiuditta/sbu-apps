import Foundation

/// The last sighting of each device, kept on the iPhone only.
///
/// One sighting per device: a newer one replaces the older, matched by identifier or, since iOS
/// can give a device a new identifier, by the same name and kind. The log keeps the newest
/// `capacity` devices.
nonisolated struct SightingLog: Codable, Equatable, Sendable {
    static let capacity = 50
    /// A sighting whose position is less precise than this says too little to be shown.
    static let worstUsefulAccuracy = 500.0

    private(set) var sightings: [Sighting] = []

    /// Saves a sighting unless its position is too vague or an equal or newer one is already kept.
    mutating func record(_ sighting: Sighting) {
        guard sighting.place.accuracy >= 0, sighting.place.accuracy <= Self.worstUsefulAccuracy else { return }
        if let existing = sightings.firstIndex(where: { Self.isSameDevice($0, sighting) }) {
            guard sightings[existing].date < sighting.date else { return }
            sightings.remove(at: existing)
        }
        sightings.append(sighting)
        sightings.sort { $0.date > $1.date }
        if sightings.count > Self.capacity {
            sightings.removeLast(sightings.count - Self.capacity)
        }
    }

    /// The last sighting of a device: by identifier first, then by name and kind.
    func latest(id: UUID, name: String?, kind: DeviceKind) -> Sighting? {
        if let exact = sightings.first(where: { $0.id == id }) {
            return exact
        }
        guard let name else { return nil }
        return sightings.first { $0.name == name && $0.kind == kind }
    }

    /// Sightings since `date`, newest first, leaving out the given devices (those heard now).
    func recent(since date: Date, excluding ids: Set<UUID>) -> [Sighting] {
        sightings.filter { $0.date >= date && !ids.contains($0.id) }
    }

    mutating func removeAll() {
        sightings.removeAll()
    }

    private static func isSameDevice(_ lhs: Sighting, _ rhs: Sighting) -> Bool {
        lhs.id == rhs.id || (lhs.name == rhs.name && lhs.kind == rhs.kind)
    }
}
