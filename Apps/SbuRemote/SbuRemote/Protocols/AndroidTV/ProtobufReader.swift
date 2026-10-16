import Foundation

/// Reads the top-level fields of a protobuf message: varints and length-delimited bytes.
/// Unknown wire types (64-bit, 32-bit) are skipped.
///
/// The bytes come from a device on the network, so nothing here trusts them: every length is
/// bounded by the bytes actually there before it becomes an `Int`, varints stop at 10 bytes,
/// and frames are capped at `maximumFrameSize`. Malformed input gives `nil` or an error, never a trap.
nonisolated struct ProtobufReader {
    /// A protobuf varint is at most 10 bytes (64 bits, 7 per byte).
    static let maximumVarintLength = 10
    /// The largest frame Sbu Remote accepts from a TV; Remote v2 messages are far smaller.
    static let maximumFrameSize = 64 * 1024

    enum FrameError: Error, Equatable {
        /// A frame declared, or a buffer grew, past `maximumFrameSize`.
        case tooLarge
        /// A length prefix longer than a varint can be.
        case malformed
    }

    private(set) var varints: [Int: Int] = [:]
    private(set) var fields: [Int: Data] = [:]

    init?(_ data: Data) {
        let bytes = [UInt8](data)
        var index = 0
        while index < bytes.count {
            guard let key = Self.readVarint(bytes, &index) else { return nil }
            let field = Int(truncatingIfNeeded: key >> 3)
            switch key & 7 {
            case 0:
                guard let value = Self.readVarint(bytes, &index) else { return nil }
                varints[field] = Int(truncatingIfNeeded: Int64(bitPattern: value))
            case 2:
                guard let length = Self.readVarint(bytes, &index), length <= UInt64(bytes.count - index) else { return nil }
                let end = index + Int(length)
                fields[field] = Data(bytes[index ..< end])
                index = end
            case 1:
                guard bytes.count - index >= 8 else { return nil }
                index += 8
            case 5:
                guard bytes.count - index >= 4 else { return nil }
                index += 4
            default:
                return nil
            }
        }
    }

    func message(_ field: Int) -> ProtobufReader? {
        fields[field].flatMap(ProtobufReader.init)
    }

    func string(_ field: Int) -> String? {
        fields[field].map { String(decoding: $0, as: UTF8.self) }
    }

    /// The varint at `index`, advancing past it; `nil` when the bytes end first or it runs
    /// past 10 bytes. `index` is only moved on success.
    static func readVarint(_ bytes: [UInt8], _ index: inout Int) -> UInt64? {
        var result: UInt64 = 0
        var cursor = index
        for position in 0 ..< maximumVarintLength {
            guard cursor < bytes.count else { return nil }
            let byte = bytes[cursor]
            cursor += 1
            result |= UInt64(byte & 0x7f) << UInt64(7 * position)
            if byte & 0x80 == 0 {
                index = cursor
                return result
            }
        }
        return nil
    }

    /// Splits a stream of length-prefixed messages; returns whole messages and leaves the rest
    /// in `buffer`. Throws when a frame is too large or its prefix is not a varint: the caller
    /// closes the connection.
    static func takeDelimited(from buffer: inout Data) throws -> [Data] {
        var messages: [Data] = []
        var bytes = [UInt8](buffer)
        var start = 0
        while start < bytes.count {
            var index = start
            guard let length = readVarint(bytes, &index) else {
                // Ten bytes and still no end: not a prefix, whatever comes next.
                if bytes.count - start >= maximumVarintLength { throw FrameError.malformed }
                break
            }
            guard length <= UInt64(maximumFrameSize) else { throw FrameError.tooLarge }
            guard length <= UInt64(bytes.count - index) else { break }
            let end = index + Int(length)
            messages.append(Data(bytes[index ..< end]))
            start = end
        }
        bytes.removeFirst(start)
        guard bytes.count <= maximumFrameSize + maximumVarintLength else { throw FrameError.tooLarge }
        buffer = Data(bytes)
        return messages
    }
}
