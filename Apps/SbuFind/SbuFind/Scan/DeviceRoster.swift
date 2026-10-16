import Foundation

/// The devices heard in this scan, kept in memory only: nothing is saved.
///
/// Each advertisement updates its device and its filtered signal; a device silent for longer
/// than `staleInterval` leaves. The list is sorted by filtered signal, strongest first.
nonisolated struct DeviceRoster: Sendable {
    /// How long a device stays listed after its last advertisement. Most devices advertise
    /// several times a second; some slow down to one every few seconds to save battery.
    static let staleInterval: TimeInterval = 10

    private struct Entry: Sendable {
        var device: NearbyDevice
        var filter: SignalFilter
    }

    private var entries: [UUID: Entry] = [:]

    var isEmpty: Bool { entries.isEmpty }

    /// Every device, named or not.
    var count: Int { entries.count }

    /// Takes in one advertisement. One without a valid signal only keeps a known device alive.
    mutating func record(_ advertisement: Advertisement) {
        if var entry = entries[advertisement.id] {
            entry.device.lastSeen = max(entry.device.lastSeen, advertisement.date)
            if let name = advertisement.name {
                entry.device.name = name
            }
            // A guess from a richer advertisement is not undone by a bare one.
            let kind = DeviceKind(advertisement: advertisement.named(entry.device.name))
            if kind != .other {
                entry.device.kind = kind
            }
            if advertisement.hasValidRSSI {
                entry.device.signal = entry.filter.add(advertisement.rssi)
            }
            entries[advertisement.id] = entry
        } else if advertisement.hasValidRSSI {
            var filter = SignalFilter()
            let signal = filter.add(advertisement.rssi)
            let device = NearbyDevice(
                id: advertisement.id,
                name: advertisement.name,
                kind: DeviceKind(advertisement: advertisement),
                signal: signal,
                lastSeen: advertisement.date
            )
            entries[advertisement.id] = Entry(device: device, filter: filter)
        }
    }

    /// Drops the devices not heard for longer than `staleInterval` before `now`, and returns them.
    @discardableResult
    mutating func removeStale(at now: Date) -> [NearbyDevice] {
        let stale = entries.values.filter { now.timeIntervalSince($0.device.lastSeen) > Self.staleInterval }.map(\.device)
        for device in stale {
            entries[device.id] = nil
        }
        return stale
    }

    mutating func removeAll() {
        entries.removeAll()
    }

    func device(id: UUID) -> NearbyDevice? {
        entries[id]?.device
    }

    /// The devices to list, strongest signal first; ties by name, then by identifier, so the
    /// order holds still between two equal readings.
    func devices(includingUnnamed: Bool) -> [NearbyDevice] {
        entries.values
            .map(\.device)
            .filter { includingUnnamed || $0.hasName }
            .sorted(by: Self.isListedBefore)
    }

    /// How many devices without a name the list leaves out when it hides them.
    var unnamedCount: Int {
        entries.values.count { !$0.device.hasName }
    }

    /// By whole dBm, so two devices a fraction apart keep their order by name.
    private static func isListedBefore(_ lhs: NearbyDevice, _ rhs: NearbyDevice) -> Bool {
        let left = lhs.signal.rounded(), right = rhs.signal.rounded()
        if left != right {
            return left > right
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
