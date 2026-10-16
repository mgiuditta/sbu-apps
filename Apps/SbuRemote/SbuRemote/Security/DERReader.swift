import Foundation

/// Reads DER tag-length-value elements one after the other.
nonisolated struct DERReader {
    private let bytes: [UInt8]
    private var index = 0

    init(_ data: Data) {
        bytes = [UInt8](data)
    }

    var isAtEnd: Bool { index >= bytes.count }

    /// The content of the next element if it has `tag`; `nil` and no progress otherwise.
    mutating func read(tag: UInt8) -> Data? {
        var cursor = index
        guard cursor < bytes.count, bytes[cursor] == tag else { return nil }
        cursor += 1
        guard cursor < bytes.count else { return nil }
        var length = Int(bytes[cursor])
        cursor += 1
        if length & 0x80 != 0 {
            let count = length & 0x7f
            guard (1...4).contains(count), cursor + count <= bytes.count else { return nil }
            length = bytes[cursor ..< cursor + count].reduce(0) { $0 << 8 | Int($1) }
            cursor += count
        }
        guard cursor + length <= bytes.count else { return nil }
        index = cursor + length
        return Data(bytes[cursor ..< cursor + length])
    }
}
