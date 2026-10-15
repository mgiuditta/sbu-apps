import Compression
import Foundation
import Testing
@testable import SbuInventory

struct ZipTests {
    @Test func crcMatchesTheStandardCheckValue() {
        #expect(CRC32.checksum(Data("123456789".utf8)) == 0xCBF4_3926)
        #expect(CRC32.checksum(Data()) == 0)
    }

    @Test func writtenArchiveReadsBackEveryFile() throws {
        let url = URL.temporaryDirectory.appending(path: "zip-\(UUID().uuidString).zip")
        defer { try? FileManager.default.removeItem(at: url) }
        let photo = Data((0..<70_000).map { UInt8($0 % 251) })
        let writer = try ZipWriter(url: url)
        try writer.add("inventory.csv", data: Data("nome\nTrapano\n".utf8))
        try writer.add("photos/àccento.heic", data: photo)
        try writer.add("empty.txt", data: Data())
        try writer.finish()

        let files = try ZipReader.files(in: Data(contentsOf: url))
        #expect(files.count == 3)
        #expect(files["inventory.csv"] == Data("nome\nTrapano\n".utf8))
        #expect(files["photos/àccento.heic"] == photo)
        #expect(files["empty.txt"] == Data())
    }

    @Test func archiveHasTheStandardSignatures() throws {
        let url = URL.temporaryDirectory.appending(path: "zip-\(UUID().uuidString).zip")
        defer { try? FileManager.default.removeItem(at: url) }
        let writer = try ZipWriter(url: url)
        try writer.add("a.txt", data: Data("a".utf8))
        try writer.finish()
        let data = try Data(contentsOf: url)
        #expect(data.readLE(UInt32.self, at: 0) == 0x0403_4B50)
        #expect(data.readLE(UInt32.self, at: data.count - 22) == 0x0605_4B50)
        #expect(data.readLE(UInt16.self, at: data.count - 12) == 1)
    }

    @Test func deflatedEntriesFromOtherZipToolsRead() throws {
        let text = Data(String(repeating: "Sbu Inventory, ", count: 200).utf8)
        let archive = try Self.deflatedArchive(name: "inventory.csv", data: text)
        #expect(try ZipReader.files(in: archive)["inventory.csv"] == text)
    }

    @Test func damagedOrForeignDataFails() throws {
        #expect(throws: ZipReader.Failure.notAZip) { try ZipReader.files(in: Data("not a zip at all, really not".utf8)) }
        var archive = try Self.deflatedArchive(name: "a.txt", data: Data("hello hello hello".utf8))
        // A byte of the compressed data, after the 30-byte header and the 5-byte name.
        archive[36] ^= 0xFF
        #expect(throws: ZipReader.Failure.self) { try ZipReader.files(in: archive) }
    }

    /// One entry compressed with raw DEFLATE, as Finder and Files write them.
    private static func deflatedArchive(name: String, data: Data) throws -> Data {
        var compressed = Data(count: data.count + 64)
        let size = compressed.withUnsafeMutableBytes { destination in
            data.withUnsafeBytes { source in
                compression_encode_buffer(destination.bindMemory(to: UInt8.self).baseAddress!, destination.count,
                                          source.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_ZLIB)
            }
        }
        try #require(size > 0)
        compressed = compressed.prefix(size)
        let nameData = Data(name.utf8)
        let crc = CRC32.checksum(data)
        var archive = Data()
        archive.append(le: UInt32(0x0403_4B50))
        archive.append(le: UInt16(20)); archive.append(le: UInt16(0)); archive.append(le: UInt16(8))
        archive.append(le: UInt16(0)); archive.append(le: UInt16(0))
        archive.append(le: crc); archive.append(le: UInt32(compressed.count)); archive.append(le: UInt32(data.count))
        archive.append(le: UInt16(nameData.count)); archive.append(le: UInt16(0))
        archive.append(nameData)
        archive.append(compressed)
        let directoryOffset = archive.count
        archive.append(le: UInt32(0x0201_4B50))
        archive.append(le: UInt16(20)); archive.append(le: UInt16(20)); archive.append(le: UInt16(0)); archive.append(le: UInt16(8))
        archive.append(le: UInt16(0)); archive.append(le: UInt16(0))
        archive.append(le: crc); archive.append(le: UInt32(compressed.count)); archive.append(le: UInt32(data.count))
        archive.append(le: UInt16(nameData.count)); archive.append(le: UInt16(0)); archive.append(le: UInt16(0))
        archive.append(le: UInt16(0)); archive.append(le: UInt16(0)); archive.append(le: UInt32(0)); archive.append(le: UInt32(0))
        archive.append(nameData)
        let directorySize = archive.count - directoryOffset
        archive.append(le: UInt32(0x0605_4B50))
        archive.append(le: UInt16(0)); archive.append(le: UInt16(0)); archive.append(le: UInt16(1)); archive.append(le: UInt16(1))
        archive.append(le: UInt32(directorySize)); archive.append(le: UInt32(directoryOffset)); archive.append(le: UInt16(0))
        return archive
    }
}
