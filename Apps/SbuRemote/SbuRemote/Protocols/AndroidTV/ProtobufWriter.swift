import Foundation

/// The little of protobuf the Android TV Remote v2 messages need, written by hand so the app
/// has no dependency: varints and length-delimited fields (proto3 wire format).
nonisolated struct ProtobufWriter {
    private(set) var data = Data()

    /// A varint field (`int32`, `uint32`, `enum`, `bool`). Zero is written too: proto2 `required` fields need it.
    mutating func varint(_ field: Int, _ value: Int) {
        tag(field, wireType: 0)
        Self.appendVarint(UInt64(bitPattern: Int64(value)), to: &data)
    }

    mutating func bytes(_ field: Int, _ value: Data) {
        tag(field, wireType: 2)
        Self.appendVarint(UInt64(value.count), to: &data)
        data.append(value)
    }

    mutating func string(_ field: Int, _ value: String) {
        bytes(field, Data(value.utf8))
    }

    mutating func message(_ field: Int, _ build: (inout ProtobufWriter) -> Void) {
        var nested = ProtobufWriter()
        build(&nested)
        bytes(field, nested.data)
    }

    private mutating func tag(_ field: Int, wireType: UInt64) {
        Self.appendVarint(UInt64(field) << 3 | wireType, to: &data)
    }

    static func appendVarint(_ value: UInt64, to data: inout Data) {
        var value = value
        while value >= 0x80 {
            data.append(UInt8(value & 0x7f) | 0x80)
            value >>= 7
        }
        data.append(UInt8(value))
    }

    /// A message preceded by its length as a varint, as both Android TV ports frame them.
    static func delimited(_ message: Data) -> Data {
        var framed = Data()
        appendVarint(UInt64(message.count), to: &framed)
        framed.append(message)
        return framed
    }
}
