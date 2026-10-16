import Foundation
import Testing
@testable import SbuRemote

/// Bytes from a TV on the network must never crash the app.
struct ProtobufSafetyTests {
    /// Field 1, wire type 2, then a 10-byte varint length of 2^64 - 1.
    private static let hugeLength: [UInt8] = [0x0a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x00]

    @Test func hugeVarintLengthIsRejectedNotTrapped() {
        #expect(ProtobufReader(Data(Self.hugeLength)) == nil)
    }

    @Test func lengthJustPastTheEndIsRejected() {
        #expect(ProtobufReader(Data([0x0a, 0x03, 0x61, 0x62])) == nil)
    }

    @Test func overlongVarintIsRejected() {
        let eleven = [UInt8](repeating: 0x80, count: 10) + [0x01]
        var index = 0
        #expect(ProtobufReader.readVarint(eleven, &index) == nil)
        #expect(index == 0)
        #expect(ProtobufReader(Data([0x08] + eleven)) == nil)
    }

    @Test func tenByteVarintIsTheLongestAccepted() {
        let ten: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01]
        var index = 0
        #expect(ProtobufReader.readVarint(ten, &index) == UInt64.max)
        #expect(index == 10)
    }

    @Test func truncatedFixedWidthFieldsAreRejected() {
        #expect(ProtobufReader(Data([0x09, 0x01, 0x02])) == nil) // 64-bit with 2 bytes
        #expect(ProtobufReader(Data([0x0d, 0x01])) == nil) // 32-bit with 1 byte
    }

    @Test func truncatedFrameWaitsForTheRest() throws {
        var buffer = Data([0x05, 0x01, 0x02])
        #expect(try ProtobufReader.takeDelimited(from: &buffer).isEmpty)
        #expect(buffer == Data([0x05, 0x01, 0x02]))
        buffer.append(contentsOf: [0x03, 0x04, 0x05])
        #expect(try ProtobufReader.takeDelimited(from: &buffer) == [Data([1, 2, 3, 4, 5])])
    }

    @Test func truncatedLengthPrefixWaitsForTheRest() throws {
        var buffer = Data([0x80])
        #expect(try ProtobufReader.takeDelimited(from: &buffer).isEmpty)
        #expect(buffer == Data([0x80]))
    }

    @Test func frameDeclaredOver64KiBClosesTheConnection() {
        var buffer = Data()
        ProtobufWriter.appendVarint(UInt64(ProtobufReader.maximumFrameSize + 1), to: &buffer)
        #expect(throws: ProtobufReader.FrameError.tooLarge) {
            try ProtobufReader.takeDelimited(from: &buffer)
        }
    }

    @Test func frameOfExactly64KiBIsAccepted() throws {
        var buffer = ProtobufWriter.delimited(Data(count: ProtobufReader.maximumFrameSize))
        #expect(try ProtobufReader.takeDelimited(from: &buffer).first?.count == ProtobufReader.maximumFrameSize)
    }

    @Test func hugeDeclaredLengthClosesTheConnection() {
        var buffer = Data(Self.hugeLength.dropFirst())
        #expect(throws: ProtobufReader.FrameError.tooLarge) {
            try ProtobufReader.takeDelimited(from: &buffer)
        }
    }

    @Test func overlongLengthPrefixClosesTheConnection() {
        var buffer = Data(repeating: 0x80, count: 10) + Data([0x01])
        #expect(throws: ProtobufReader.FrameError.malformed) {
            try ProtobufReader.takeDelimited(from: &buffer)
        }
    }
}
