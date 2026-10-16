import Foundation

/// The DER elements an X.509 certificate needs, encoded by hand.
nonisolated enum DER {
    static func element(tag: UInt8, _ content: Data) -> Data {
        var data = Data([tag])
        data.append(length(content.count))
        data.append(content)
        return data
    }

    static func length(_ count: Int) -> Data {
        if count < 0x80 { return Data([UInt8(count)]) }
        var bytes: [UInt8] = []
        var value = count
        while value > 0 {
            bytes.insert(UInt8(value & 0xff), at: 0)
            value >>= 8
        }
        return Data([0x80 | UInt8(bytes.count)] + bytes)
    }

    static func sequence(_ elements: Data...) -> Data {
        element(tag: 0x30, elements.reduce(Data(), +))
    }

    static func set(_ elements: Data...) -> Data {
        element(tag: 0x31, elements.reduce(Data(), +))
    }

    /// A non-negative integer from big-endian bytes, with the leading zero DER needs when the top bit is set.
    static func integer(_ bigEndian: Data) -> Data {
        var content = Data(bigEndian.drop { $0 == 0 })
        if content.isEmpty { content = Data([0]) }
        if let first = content.first, first & 0x80 != 0 { content.insert(0, at: 0) }
        return element(tag: 0x02, content)
    }

    static func integer(_ value: Int) -> Data {
        var bytes: [UInt8] = []
        var remaining = value
        repeat {
            bytes.insert(UInt8(remaining & 0xff), at: 0)
            remaining >>= 8
        } while remaining > 0
        return integer(Data(bytes))
    }

    static let null = Data([0x05, 0x00])

    /// An object identifier from its dotted form, such as `1.2.840.113549.1.1.11`.
    static func objectIdentifier(_ dotted: String) -> Data {
        let arcs = dotted.split(separator: ".").compactMap { Int($0) }
        guard arcs.count >= 2 else { return element(tag: 0x06, Data()) }
        var content = Data([UInt8(arcs[0] * 40 + arcs[1])])
        for arc in arcs.dropFirst(2) {
            var chunk = [UInt8(arc & 0x7f)]
            var value = arc >> 7
            while value > 0 {
                chunk.insert(UInt8(value & 0x7f) | 0x80, at: 0)
                value >>= 7
            }
            content.append(contentsOf: chunk)
        }
        return element(tag: 0x06, content)
    }

    static func utf8String(_ text: String) -> Data {
        element(tag: 0x0c, Data(text.utf8))
    }

    /// `YYMMDDHHMMSSZ` in UTC, valid for years 1950-2049.
    static func utcTime(_ date: Date) -> Data {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let numbers = [(parts.year ?? 2000) % 100, parts.month ?? 1, parts.day ?? 1, parts.hour ?? 0, parts.minute ?? 0, parts.second ?? 0]
        let text = numbers.map { $0 < 10 ? "0\($0)" : "\($0)" }.joined() + "Z"
        return element(tag: 0x17, Data(text.utf8))
    }

    /// A BIT STRING with no unused bits.
    static func bitString(_ content: Data) -> Data {
        element(tag: 0x03, Data([0]) + content)
    }

    /// An explicit context-specific tag, such as `[0]` for the certificate version.
    static func explicit(_ number: UInt8, _ content: Data) -> Data {
        element(tag: 0xa0 | number, content)
    }
}
