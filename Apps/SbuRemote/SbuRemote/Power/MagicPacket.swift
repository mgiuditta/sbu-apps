import Foundation

/// The Wake-on-LAN magic packet: six 0xFF bytes, then the MAC address sixteen times (AMD, public).
nonisolated enum MagicPacket {
    static let port: UInt16 = 9

    static func packet(for macAddress: String) -> Data? {
        guard let mac = MACAddress.bytes(macAddress) else { return nil }
        var data = Data(repeating: 0xff, count: 6)
        for _ in 0 ..< 16 { data.append(contentsOf: mac) }
        return data
    }

    /// Where the packet goes: the broadcast address with the multicast entitlement (#360),
    /// otherwise the TV's last address, which reaches it only while the router still knows it.
    static func destination(host: String, isBroadcastAllowed: Bool) -> String {
        isBroadcastAllowed ? "255.255.255.255" : host
    }
}
