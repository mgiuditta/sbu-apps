import Foundation

/// Finds your saved devices among the devices heard now.
///
/// First by the identifier each was last heard under; then, for the ones whose identifier iOS
/// changed, by the same advertised name and kind, and the same maker when both say one. A match
/// is accepted only when it is the only candidate: two "Buds Pro" heard at once could be yours
/// or a neighbour's, so neither is claimed. A device heard is claimed by one saved device at most.
nonisolated enum DeviceMatcher {
    /// The device heard now for each saved device that has one, by saved device id.
    static func match(_ saved: [SavedDevice], among devices: [NearbyDevice]) -> [UUID: NearbyDevice] {
        var matches: [UUID: NearbyDevice] = [:]
        var taken = Set<UUID>()

        for mine in saved {
            if let device = devices.first(where: { $0.id == mine.deviceID }) {
                matches[mine.id] = device
                taken.insert(device.id)
            }
        }

        for mine in saved where matches[mine.id] == nil {
            guard let name = mine.advertisedName else { continue }
            let candidates = devices.filter { device in
                !taken.contains(device.id)
                    && device.name == name
                    && device.kind == mine.kind
                    && isSameMaker(mine.companyID, device.companyID)
            }
            // Two saved devices with the same description cannot tell them apart either.
            let twins = saved.filter { $0.id != mine.id && matches[$0.id] == nil && $0.advertisedName == name && $0.kind == mine.kind }
            guard candidates.count == 1, twins.isEmpty, let device = candidates.first else { continue }
            matches[mine.id] = device
            taken.insert(device.id)
        }
        return matches
    }

    /// Makers differ only when both are known and not equal.
    private static func isSameMaker(_ lhs: UInt16?, _ rhs: UInt16?) -> Bool {
        guard let lhs, let rhs else { return true }
        return lhs == rhs
    }
}
