import Foundation

/// A TV the user paired, kept on the device. Its credentials live in the Keychain, never here.
nonisolated struct SavedTV: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    /// The name the TV reports, or the one the user typed.
    var name: String
    var brand: TVBrand
    /// IPv4 address or local host name on the home network.
    var host: String
    /// Hardware address for Wake-on-LAN, `AA:BB:CC:DD:EE:FF`, when the TV told us.
    var macAddress: String?
    /// Model the TV reports, shown in settings.
    var model: String?

    init(id: UUID = UUID(), name: String, brand: TVBrand, host: String, macAddress: String? = nil, model: String? = nil) {
        self.id = id
        self.name = name
        self.brand = brand
        self.host = host
        self.macAddress = macAddress
        self.model = model
    }
}

extension SavedTV {
    /// A living-room TV for previews and tests.
    static let sample = SavedTV(name: "Soggiorno", brand: .samsung, host: "192.168.1.20", macAddress: "A0:B1:C2:D3:E4:F5", model: "QE55Q80")
}
