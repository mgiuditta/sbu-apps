import Foundation

/// Turns devices falling silent into sightings: it remembers where the iPhone was the last
/// time each device was heard, so a device dropped from the list ten seconds later is placed
/// where it was heard, not where you walked since.
nonisolated struct SightingRecorder: Sendable {
    /// A device counts as heard at a refresh when its last advertisement is this recent.
    static let heardWithin: TimeInterval = 2

    private var places: [UUID: Coordinate] = [:]

    /// Notes where the iPhone is for every device heard just now.
    mutating func note(_ devices: [NearbyDevice], at now: Date, place: Coordinate?) {
        guard let place else { return }
        for device in devices where now.timeIntervalSince(device.lastSeen) <= Self.heardWithin {
            places[device.id] = place
        }
    }

    /// Sightings for devices that are no longer heard: only named ones with a known place.
    mutating func sightings(for gone: [NearbyDevice], fallback: Coordinate?) -> [Sighting] {
        gone.compactMap { device in
            defer { places[device.id] = nil }
            guard let name = device.name, let place = places[device.id] ?? fallback else { return nil }
            return Sighting(id: device.id, name: name, kind: device.kind, date: device.lastSeen, place: place)
        }
    }

    mutating func reset() {
        places.removeAll()
    }
}
