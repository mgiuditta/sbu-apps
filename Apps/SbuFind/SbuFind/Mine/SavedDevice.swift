import Foundation

/// A device you pinned to the top of the list with a name of your own.
///
/// iOS can give the same device a new identifier, so besides the last one it was heard under,
/// it keeps what the device says about itself: its advertised name, its kind and its maker.
nonisolated struct SavedDevice: Codable, Equatable, Identifiable, Sendable {
    /// Stable for the life of the saved device, whatever identifier iOS uses.
    let id: UUID
    /// The name you gave it.
    var name: String
    /// The identifier it was last heard under.
    var deviceID: UUID
    /// The name the device advertises; `nil` for a device that says none.
    var advertisedName: String?
    var kind: DeviceKind
    var companyID: UInt16?

    init(id: UUID = UUID(), name: String, device: NearbyDevice) {
        self.id = id
        self.name = name
        deviceID = device.id
        advertisedName = device.name
        kind = device.kind
        companyID = device.companyID
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
