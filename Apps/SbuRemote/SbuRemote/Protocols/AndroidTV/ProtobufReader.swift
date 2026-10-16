import Foundation

/// Reads the top-level fields of a protobuf message: varints and length-delimited bytes.
/// Unknown wire types (64-bit, 32-bit) are skipped.
nonisolated struct ProtobufReader {
    private(set) var varints: [Int: Int] = [:]
    private(set) var fields: [Int: Data] = [:]

    init?(_ data: Data) {
        let bytes = [UInt8](data)
        var index = 0
        while index < bytes.count {
            guard let key = Self.readVarint(bytes, &index) else { return nil }
            let field = Int(key >> 3)
            switch key & 7 {
            case 0:
                guard let value = Self.readVarint(bytes, &index) else { return nil }
                varints[field] = Int(truncatingIfNeeded: Int64(bitPattern: value))
            case 2:
                guard let length = Self.readVarint(bytes, &index), index + Int(length) <= bytes.count else { return nil }
                fields[field] = Data(bytes[index ..< index + Int(length)])
                index += Int(length)
            case 1:
                index += 8
            case 5:
                index += 4
            default:
                return nil
            }
        }
        guard index == bytes.count else { return nil }
    }

    func message(_ field: Int) -> ProtobufReader? {
        fields[field].flatMap(ProtobufReader.init)
    }

    func string(_ field: Int) -> String? {
        fields[field].map { String(decoding: $0, as: UTF8.self) }
    }

    static func readVarint(_ bytes: [UInt8], _ index: inout Int) -> UInt64? {
        var result: UInt64 = 0
        var shift: UInt64 = 0
        while index < bytes.count, shift < 64 {
            let byte = bytes[index]
            index += 1
            result |= UInt64(byte & 0x7f) << shift
            if byte & 0x80 == 0 { return result }
            shift += 7
        }
        return nil
    }

    /// Splits a stream of length-prefixed messages; returns whole messages and leaves the rest in `buffer`.
    static func takeDelimited(from buffer: inout Data) -> [Data] {
        var messages: [Data] = []
        while true {
            let bytes = [UInt8](buffer)
            var index = 0
            guard let length = readVarint(bytes, &index), index + Int(length) <= bytes.count else { break }
            messages.append(Data(bytes[index ..< index + Int(length)]))
            buffer = Data(bytes[(index + Int(length))...])
        }
        return messages
    }
}
