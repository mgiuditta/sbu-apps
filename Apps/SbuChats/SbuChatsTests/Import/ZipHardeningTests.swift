import Foundation
import Testing
@testable import SbuChats

/// Crafted archives: every hostile header must end in a `ZipError`, never a trap or a runaway buffer.
struct ZipHardeningTests {
    /// A copy of `name` with `patch` applied to its bytes.
    private func crafted(_ name: String, _ patch: (inout [UInt8]) -> Void) throws -> URL {
        let url = try Fixture.copy(name)
        var bytes = try [UInt8](Data(contentsOf: url))
        patch(&bytes)
        try Data(bytes).write(to: url)
        return url
    }

    private func write(_ value: UInt64, width: Int, at offset: Int, in bytes: inout [UInt8]) {
        for index in 0 ..< width {
            bytes[offset + index] = UInt8(truncatingIfNeeded: value >> (8 * UInt64(index)))
        }
    }

    private func readUInt32(_ bytes: [UInt8], at offset: Int) -> Int {
        (0 ..< 4).reduce(0) { $0 | Int(bytes[offset + $1]) << (8 * $1) }
    }

    /// The end record of an archive without a comment is its last 22 bytes.
    private func endRecord(_ bytes: [UInt8]) -> Int { bytes.count - 22 }

    private func centralEntry(_ bytes: [UInt8]) -> Int { readUInt32(bytes, at: endRecord(bytes) + 16) }

    private func openingFails(_ url: URL) -> ZipError? {
        do {
            _ = try ZipArchive(url: url)
            return nil
        } catch {
            return error
        }
    }

    @Test func aLocalHeaderOffsetPastTheFileIsDamaged() throws {
        let url = try crafted("android-stored.zip") { bytes in
            write(0xFFFF_FFF0, width: 4, at: centralEntry(bytes) + 42, in: &bytes)
        }
        #expect(openingFails(url) == .damaged)
    }

    @Test func aCompressedSizeLargerThanTheFileIsDamaged() throws {
        let url = try crafted("android-stored.zip") { bytes in
            write(0xFFFF_FFFE, width: 4, at: centralEntry(bytes) + 20, in: &bytes)
        }
        #expect(openingFails(url) == .damaged)
    }

    @Test func aDirectoryOffsetPastTheFileIsDamaged() throws {
        let url = try crafted("android-stored.zip") { bytes in
            write(0xFFFF_FFFF, width: 4, at: endRecord(bytes) + 16, in: &bytes)
        }
        #expect(openingFails(url) == .damaged)
    }

    @Test func aZip64DirectoryOffsetThatOverflowsIsDamaged() throws {
        let url = try crafted("zip64.zip") { bytes in
            let locator = endRecord(bytes) - 20
            let end64 = readUInt32(bytes, at: locator + 8)
            write(UInt64.max - 2, width: 8, at: end64 + 48, in: &bytes)
        }
        #expect(openingFails(url) == .damaged)
    }

    @Test func aZip64EndRecordOffsetThatOverflowsIsDamaged() throws {
        let url = try crafted("zip64.zip") { bytes in
            write(UInt64.max - 10, width: 8, at: endRecord(bytes) - 20 + 8, in: &bytes)
        }
        #expect(openingFails(url) == .damaged)
    }

    @Test func moreEntriesThanTheDirectoryHoldsIsDamaged() throws {
        let url = try crafted("android-stored.zip") { bytes in
            write(0xFFFF, width: 2, at: endRecord(bytes) + 8, in: &bytes)
            write(0xFFFF, width: 2, at: endRecord(bytes) + 10, in: &bytes)
        }
        #expect(openingFails(url) == .damaged)
    }

    @Test func aMillionEntriesIsTooLarge() throws {
        let url = try crafted("zip64.zip") { bytes in
            let end64 = readUInt32(bytes, at: endRecord(bytes) - 20 + 8)
            write(1_000_000, width: 8, at: end64 + 32, in: &bytes)
        }
        #expect(openingFails(url) == .tooLarge)
    }

    @Test func aStoredEntryWhoseSizesDisagreeIsDamaged() throws {
        let url = try crafted("android-stored.zip") { bytes in
            write(5, width: 4, at: centralEntry(bytes) + 24, in: &bytes)
        }
        let archive = try ZipArchive(url: url)
        #expect(throws: ZipError.damaged) {
            try archive.read(archive.entries[0]) { _ in }
        }
    }

    @Test func aRatioBombIsRefusedBeforeInflating() throws {
        let archive = try ZipArchive(url: Fixture.url("bomb-ratio.zip"))
        var inflated = 0
        #expect(throws: ZipError.tooLarge) {
            try archive.read(archive.entries[0]) { inflated += $0.count }
        }
        #expect(inflated == 0)
    }

    @Test func anEntryThatInflatesPastItsDeclaredSizeStopsAtTheCeiling() throws {
        let archive = try ZipArchive(url: Fixture.url("bomb-lying-size.zip"))
        #expect(archive.entries[0].uncompressedSize == 100)
        var inflated = 0
        #expect(throws: ZipError.tooLarge) {
            try archive.read(archive.entries[0]) { inflated += $0.count }
        }
        #expect(inflated <= 100)
    }

    @Test func anEntryLargerThanTheCallerAllowsIsTooLarge() throws {
        let archive = try ZipArchive(url: Fixture.url("WhatsApp Chat - Anna Rossi.zip"))
        #expect(throws: ZipError.tooLarge) {
            try archive.read(archive.entries[0], maximumSize: 64) { _ in }
        }
    }

    @Test(arguments: ["bomb-ratio.zip", "bomb-lying-size.zip"])
    func importingABombSaysTheFileIsTooLarge(name: String) async throws {
        let store = try ChatStore(url: nil)
        await #expect(throws: ImportFailure.tooLarge) {
            try await store.importChat(from: Fixture.url(name), knownOwners: [])
        }
        #expect(try await store.chats().isEmpty)
    }

    @Test func randomGarbageNeverTraps() throws {
        // Every truncation and a byte flip at every 7th position of a real archive: errors only.
        let original = try [UInt8](Data(contentsOf: Fixture.url("zip64.zip")))
        for length in stride(from: 0, through: original.count, by: 3) {
            let url = try Fixture.textFile("", name: "cut.zip")
            try Data(original.prefix(length)).write(to: url)
            if let archive = try? ZipArchive(url: url), let entry = archive.entries.first {
                _ = try? archive.read(entry, maximumSize: 1 << 20) { _ in }
            }
        }
        for position in stride(from: 0, to: original.count, by: 7) {
            var bytes = original
            bytes[position] ^= 0xFF
            let url = try Fixture.textFile("", name: "flip.zip")
            try Data(bytes).write(to: url)
            if let archive = try? ZipArchive(url: url), let entry = archive.entries.first {
                _ = try? archive.read(entry, maximumSize: 1 << 20) { _ in }
            }
        }
    }
}
