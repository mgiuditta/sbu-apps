import Foundation

nonisolated extension Data {
    /// Lowercase hexadecimal, two characters a byte.
    var hexString: String {
        map { byte in
            let digits = String(byte, radix: 16)
            return digits.count == 1 ? "0" + digits : digits
        }
        .joined()
    }

    /// Bytes from hexadecimal text, two characters a byte; `nil` when it is not hex.
    init?(hexString: String) {
        let characters = Array(hexString)
        guard characters.count.isMultiple(of: 2) else { return nil }
        var bytes: [UInt8] = []
        bytes.reserveCapacity(characters.count / 2)
        for index in stride(from: 0, to: characters.count, by: 2) {
            guard let byte = UInt8(String(characters[index ... index + 1]), radix: 16) else { return nil }
            bytes.append(byte)
        }
        self.init(bytes)
    }
}
