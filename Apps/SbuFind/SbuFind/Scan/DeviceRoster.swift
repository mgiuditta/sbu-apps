import Foundation

/// The devices heard in this scan, kept in memory only: nothing is saved.
///
/// Each advertisement updates its device; a device silent for longer than `staleInterval`
/// leaves. The list is sorted by signal, strongest first.
nonisolated struct DeviceRoster: Sendable {
    /// How long a device stays listed after its last advertisement. Most devices advertise
    /// several times a second; some slow down to one every few seconds to save battery.
    static let staleInterval: TimeInterval = 10

    private var entries: [UUID: NearbyDevice] = [:]

    var isEmpty: Bool { entries.isEmpty }

    /// Every device, named or not.
    var count: Int { entries.count }

    /// Takes in one advertisement. One without a valid signal only keeps a known device alive.
    mutating func record(_ advertisement: Advertisement) {
        if var device = entries[advertisement.id] {
            device.lastSeen = max(device.lastSeen, advertisement.date)
            if let name = advertisement.name {
                device.name = name
            }
            // A guess from a richer advertisement is not undone by a bare one.
            let kind = DeviceKind(advertisement: advertisement.named(device.name))
            if kind != .other {
                device.kind = kind
            }
            if advertisement.hasValidRSSI {
                device.rssi = advertisement.rssi
            }
            entries[advertisement.id] = device
        } else if advertisement.hasValidRSSI {
            entries[advertisement.id] = NearbyDevice(
                id: advertisement.id,
                name: advertisement.name,
                kind: DeviceKind(advertisement: advertisement),
                rssi: advertisement.rssi,
                lastSeen: advertisement.date
            )
        }
    }

    /// Drops the devices not heard for longer than `staleInterval` before `now`.
    mutating func removeStale(at now: Date) {
        entries = entries.filter { now.timeIntervalSince($0.value.lastSeen) <= Self.staleInterval }
    }

    mutating func removeAll() {
        entries.removeAll()
    }

    func device(id: UUID) -> NearbyDevice? {
        entries[id]
    }

    /// The devices to list, strongest signal first; ties by name, then by identifier, so the
    /// order holds still between two equal readings.
    func devices(includingUnnamed: Bool) -> [NearbyDevice] {
        entries.values
            .filter { includingUnnamed || $0.hasName }
            .sorted(by: Self.isListedBefore)
    }

    /// How many devices without a name the list leaves out when it hides them.
    var unnamedCount: Int {
        entries.values.count { !$0.hasName }
    }

    private static func isListedBefore(_ lhs: NearbyDevice, _ rhs: NearbyDevice) -> Bool {
        if lhs.rssi != rhs.rssi {
            return lhs.rssi > rhs.rssi
        }
        switch (lhs.name, rhs.name) {
        case let (left?, right?) where left != right:
            return left.localizedStandardCompare(right) == .orderedAscending
        case (.some, nil):
            return true
        case (nil, .some):
            return false
        default:
            return lhs.id.uuidString < rhs.id.uuidString
        }
    }
}
