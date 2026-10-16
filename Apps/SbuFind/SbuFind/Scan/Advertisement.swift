import Foundation

/// One Bluetooth Low Energy advertisement as heard by the iPhone: who sent it, what it said, how loud.
nonisolated struct Advertisement: Equatable, Sendable {
    /// Apple's company identifier in manufacturer data, little-endian.
    static let appleCompanyID: UInt16 = 0x004C
    /// Core Bluetooth reports 127 when it could not read the signal strength.
    static let unavailableRSSI = 127

    /// The identifier iOS gives this peripheral for this app; it can change when the device rotates its address.
    let id: UUID
    /// The advertised local name, or the name iOS remembers; `nil` when the device says none.
    let name: String?
    /// Signal strength in dBm, from about -30 (touching) to -100 (barely heard).
    let rssi: Int
    let manufacturerData: Data?
    /// Advertised service UUIDs, as `CBUUID.uuidString` gives them: "180D" or a full UUID.
    let serviceUUIDs: [String]
    let date: Date

    /// - Parameter name: Trimmed; blank becomes `nil`.
    init(id: UUID, name: String?, rssi: Int, manufacturerData: Data? = nil, serviceUUIDs: [String] = [], date: Date) {
        self.id = id
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = trimmed?.isEmpty == false ? trimmed : nil
        self.rssi = rssi
        self.manufacturerData = manufacturerData
        self.serviceUUIDs = serviceUUIDs
        self.date = date
    }

    /// The same advertisement under another name: the one a device said in an earlier packet.
    func named(_ name: String?) -> Advertisement {
        Advertisement(id: id, name: name, rssi: rssi, manufacturerData: manufacturerData, serviceUUIDs: serviceUUIDs, date: date)
    }

    /// The same advertisement heard again at `date`.
    func heard(at date: Date) -> Advertisement {
        Advertisement(id: id, name: name, rssi: rssi, manufacturerData: manufacturerData, serviceUUIDs: serviceUUIDs, date: date)
    }

    /// A real reading: negative and not the 127 Core Bluetooth sends when it has none.
    var hasValidRSSI: Bool {
        rssi < 0 && rssi >= -127
    }

    /// The company that made the device, from the first two bytes of manufacturer data.
    var companyID: UInt16? {
        guard let manufacturerData, manufacturerData.count >= 2 else { return nil }
        let bytes = [UInt8](manufacturerData.prefix(2))
        return UInt16(bytes[0]) | UInt16(bytes[1]) << 8
    }

    /// The first byte after the company identifier: for Apple, the kind of Continuity message.
    var manufacturerMessageType: UInt8? {
        guard let manufacturerData, manufacturerData.count >= 3 else { return nil }
        return manufacturerData[manufacturerData.startIndex + 2]
    }
}
