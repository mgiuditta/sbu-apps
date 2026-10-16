import Foundation

/// A device the iPhone has heard recently, as the list and the finder show it.
nonisolated struct NearbyDevice: Identifiable, Equatable, Sendable {
    let id: UUID
    /// The last name it advertised; `nil` while it never said one.
    var name: String?
    var kind: DeviceKind
    /// The latest valid signal strength, in dBm.
    var rssi: Int
    var lastSeen: Date

    var hasName: Bool { name != nil }
}
