import Foundation
import SwiftData
import Testing
@testable import SbuInventory

/// An archive picked for import is untrusted: hostile or damaged ones fail with an error, never a crash
/// or an allocation the archive dictates.
struct MalformedArchiveTests {
    private func storedArchive(_ files: [(String, Data)]) throws -> Data {
        let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).zip")
        defer { try? FileManager.default.removeItem(at: url) }
        let writer = try ZipWriter(url: url)
        for (name, data) in files { try writer.add(name, data: data) }
        try writer.finish()
        return try Data(contentsOf: url)
    }

    @Test func zipBombIsRefusedBeforeInflating() throws {
        // 16 MB of zeros deflate to a few KB: an expansion no photo or text ever has.
        let bomb = try ZipTests.deflatedArchive(name: "inventory.csv", data: Data(count: 16 * 1024 * 1024))
        #expect(bomb.count < 100_000)
        #expect(throws: ZipReader.Failure.tooLarge) { try ZipReader.files(in: bomb) }
        #expect(throws: ImportFile.Failure.tooLarge) { try ImportFile(data: bomb, calendar: .current) }
    }

    @Test func streamThatOutgrowsItsDeclaredSizeIsCutOff() throws {
        let text = Data(String(repeating: "Sbu Inventory ", count: 500).utf8)
        let lying = try ZipTests.deflatedArchive(name: "a.csv", data: text, declaredSize: 100)
        #expect(throws: ZipReader.Failure.damaged) { try ZipReader.files(in: lying) }
    }

    @Test func tooManyEntriesAreRefused() throws {
        let archive = try storedArchive([("a", Data("1".utf8)), ("b", Data("2".utf8)), ("c", Data("3".utf8))])
        #expect(throws: ZipReader.Failure.tooLarge) {
            try ZipReader.files(in: archive, limits: ZipReader.Limits(maxEntries: 2))
        }
    }

    @Test func tooManyBytesInAllAreRefused() throws {
        let archive = try storedArchive([("a", Data(count: 8)), ("b", Data(count: 8))])
        #expect(throws: ZipReader.Failure.tooLarge) {
            try ZipReader.files(in: archive, limits: ZipReader.Limits(maxTotalBytes: 10))
        }
        #expect(throws: ZipReader.Failure.tooLarge) {
            try ZipReader.files(in: archive, limits: ZipReader.Limits(maxEntryBytes: 4))
        }
    }

    @Test(arguments: [
        // Central directory offset past the end of the file.
        (-6, UInt32.max),
        // Compressed and uncompressed sizes of the entry at their maximum.
        (-22 - 47 + 20, UInt32.max),
        // Local header offset past the end of the file.
        (-22 - 47 + 42, UInt32.max - 10),
    ] as [(Int, UInt32)])
    func sizesAndOffsetsBeyondTheFileFailCleanly(offsetFromEnd: Int, value: UInt32) throws {
        var archive = try storedArchive([("a", Data("hello".utf8))])
        let position = archive.count + offsetFromEnd
        withUnsafeBytes(of: value.littleEndian) { bytes in
            for (index, byte) in bytes.enumerated() { archive[position + index] = byte }
        }
        #expect(throws: ZipReader.Failure.self) { try ZipReader.files(in: archive) }
    }

    @Test func truncatedArchiveFails() throws {
        let archive = try storedArchive([("a", Data(count: 1000))])
        for length in [0, 10, 21, 500, archive.count - 1] {
            #expect(throws: ZipReader.Failure.self) { try ZipReader.files(in: archive.prefix(length)) }
        }
    }

    @Test func deepFolderPathInAFileIsCutAtTheMaximumDepth() throws {
        let container = try ModelContainer.inventory(inMemory: true)
        let path = (1...500).map { "Livello \($0)" }
        let file = ImportFile(rows: [InventoryRow(name: "In fondo", path: path)], photos: [:])
        let result = InventoryImport.apply(file, into: container.mainContext)
        #expect(result.folders == InventoryTree.maxDepth)
        let item = try #require(try container.mainContext.fetch(FetchDescriptor<Item>()).first)
        #expect(item.folder?.name == "Livello \(InventoryTree.maxDepth)")
    }
}
