import Foundation

/// A device you pinned to the top of the list with a name of your own.
///
/// iOS can give the same device a new identifier, so besides the one it was saved with, it keeps
/// what the device says about itself: its advertised name, its kind, its maker, and the services
/// it advertises, which are what iOS can listen for with the app in the background.
nonisolated struct SavedDevice: Codable, Equatable, Identifiable, Sendable {
    /// Stable for the life of the saved device, whatever identifier iOS uses.
    let id: UUID
    /// The name you gave it.
    var name: String
    /// The identifier it was saved with.
    var deviceID: UUID
    /// The name the device advertises; `nil` for a device that says none.
    var advertisedName: String?
    var kind: DeviceKind
    var companyID: UInt16?
    /// Service UUIDs it advertised, sorted. Empty for most earbuds: then it can only be followed
    /// with the app open.
    var serviceUUIDs: [String]

    init(id: UUID = UUID(), name: String, device: NearbyDevice) {
        self.id = id
        self.name = name
        deviceID = device.id
        advertisedName = device.name
        kind = device.kind
        companyID = device.companyID
        serviceUUIDs = device.serviceUUIDs.sorted()
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, deviceID, advertisedName, kind, companyID, serviceUUIDs
    }

    /// Devices saved before services were recorded decode with none.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        deviceID = try container.decode(UUID.self, forKey: .deviceID)
        advertisedName = try container.decodeIfPresent(String.self, forKey: .advertisedName)
        kind = try container.decode(DeviceKind.self, forKey: .kind)
        companyID = try container.decodeIfPresent(UInt16.self, forKey: .companyID)
        serviceUUIDs = try container.decodeIfPresent([String].self, forKey: .serviceUUIDs) ?? []
    }

    /// Whether iOS can be asked to listen for it with the app in the background.
    var canBeFollowedInBackground: Bool {
        !serviceUUIDs.isEmpty
    }

    /// The name to show: yours, trimmed; the advertised one if yours is blank.
    static func displayName(_ typed: String, fallback: String?) -> String {
        let trimmed = typed.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return String(trimmed.prefix(40))
        }
        return fallback ?? String(localized: "Senza nome")
    }
}
