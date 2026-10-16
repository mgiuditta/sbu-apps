import Foundation

/// The last time the iPhone heard a device, and where the iPhone was then: not where the device
/// is, but where to start looking.
nonisolated struct Sighting: Codable, Equatable, Identifiable, Sendable {
    /// The identifier iOS gave the device; it can change, so the name and kind also match it.
    let id: UUID
    let name: String
    let kind: DeviceKind
    /// When the device was last heard.
    let date: Date
    let place: Coordinate
}
