import Foundation

/// A device the iPhone has heard recently, as the list and the finder show it.
nonisolated struct NearbyDevice: Identifiable, Equatable, Sendable {
    let id: UUID
    /// The last name it advertised; `nil` while it never said one.
    var name: String?
    var kind: DeviceKind
    /// The filtered signal strength, in dBm: what the list sorts by and the finder shows.
    var signal: Double
    /// The latest reading as heard, before smoothing, in dBm: for the Taratura screen.
    var rawRSSI: Int?
    var lastSeen: Date
    /// The maker from the manufacturer data, when the device sends it: it tells apart two
    /// devices with the same name.
    var companyID: UInt16?

    var hasName: Bool { name != nil }

    var proximity: Proximity { Proximity(rssi: signal) }

    var warmth: Warmth { Warmth(proximity: proximity) }
}
