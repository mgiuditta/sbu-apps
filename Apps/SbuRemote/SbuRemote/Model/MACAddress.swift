import Foundation

/// A hardware address as TVs report it, for Wake-on-LAN.
nonisolated enum MACAddress {
    /// `AA:BB:CC:DD:EE:FF` from `aa:bb:cc:dd:ee:ff`, `AA-BB-…` or `aabbccddeeff`; `nil` otherwise.
    static func normalized(_ text: String) -> String? {
        bytes(text).map { $0.map { byte in
            let digits = String(byte, radix: 16, uppercase: true)
            return digits.count == 1 ? "0" + digits : digits
        }.joined(separator: ":") }
    }

    /// The six bytes of an address, `nil` when it is not one or is all zeros.
    static func bytes(_ text: String) -> [UInt8]? {
        let hex = text.filter(\.isHexDigit)
        let separators = text.filter { !$0.isHexDigit }
        guard hex.count == 12, separators.allSatisfy({ $0 == ":" || $0 == "-" || $0 == "." }) else { return nil }
        guard let data = Data(hexString: hex) else { return nil }
        let bytes = [UInt8](data)
        return bytes.allSatisfy({ $0 == 0 }) ? nil : bytes
    }
}
