import Foundation

/// A device the iPhone has heard recently, as the list and the finder show it.
nonisolated struct NearbyDevice: Identifiable, Equatable, Sendable {
    let id: UUID
    /// The last name it advertised; `nil` while it never said one.
    var name: String?
    var kind: DeviceKind
    /// The filtered signal strength, in dBm: what the list sorts by and the finder shows.
    var signal: Double
    var lastSeen: Date

    var hasName: Bool { name != nil }

    var proximity: Proximity { Proximity(rssi: signal) }

    var warmth: Warmth { Warmth(proximity: proximity) }
}
