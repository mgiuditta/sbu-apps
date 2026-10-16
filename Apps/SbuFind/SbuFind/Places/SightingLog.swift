import Foundation

/// The last sighting of each device, kept on the iPhone only.
///
/// One sighting per identifier: a newer one replaces the older. Never matched by name: Bluetooth
/// names are not authenticated, and a device nearby saying "Buds Pro" must not move the place
/// of yours. The log keeps the newest `capacity` sightings.
nonisolated struct SightingLog: Codable, Equatable, Sendable {
    static let capacity = 50
    /// A sighting whose position is less precise than this says too little to be shown.
    static let worstUsefulAccuracy = 500.0

    private(set) var sightings: [Sighting] = []

    /// Saves a sighting unless its position is too vague or an equal or newer one is already kept.
    mutating func record(_ sighting: Sighting) {
        guard sighting.place.accuracy >= 0, sighting.place.accuracy <= Self.worstUsefulAccuracy else { return }
        if let existing = sightings.firstIndex(where: { $0.id == sighting.id }) {
            guard sightings[existing].date < sighting.date else { return }
            sightings.remove(at: existing)
        }
        sightings.append(sighting)
        sightings.sort { $0.date > $1.date }
        if sightings.count > Self.capacity {
            sightings.removeLast(sightings.count - Self.capacity)
        }
    }

    /// The last sighting of the device heard under this identifier.
    func latest(id: UUID) -> Sighting? {
        sightings.first { $0.id == id }
    }

    /// Sightings since `date`, newest first, leaving out the given devices (those heard now).
    func recent(since date: Date, excluding ids: Set<UUID>) -> [Sighting] {
        sightings.filter { $0.date >= date && !ids.contains($0.id) }
    }

    mutating func removeAll() {
        sightings.removeAll()
    }
}
