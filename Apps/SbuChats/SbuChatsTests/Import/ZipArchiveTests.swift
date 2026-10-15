import Foundation
import Testing
@testable import SbuChats

struct ZipArchiveTests {
    private func text(of entryName: String, in archiveName: String) throws -> String {
        let archive = try ZipArchive(url: Fixture.url(archiveName))
        let entry = try #require(archive.entries.first { $0.path == entryName })
        var data = Data()
        try archive.read(entry) { data.append($0) }
        return String(decoding: data, as: UTF8.self)
    }

    @Test(arguments: ["WhatsApp Chat - Anna Rossi.zip", "zip64.zip"])
    func readsTheDeflatedChat(archive: String) throws {
        let chat = try text(of: "_chat.txt", in: archive)
        #expect(chat.hasPrefix("[14/03/24, 09:15:02] Anna Rossi:"))
        #expect(chat.contains("Buongiorno a te 👨‍👩‍👧"))
    }

    @Test func readsAStoredEntry() throws {
        let chat = try text(of: "WhatsApp Chat with Marta.txt", in: "android-stored.zip")
        #expect(chat.contains("Guarda che tramonto"))
    }

    @Test func listsEveryEntryAndMarksMacOSMetadata() throws {
        let archive = try ZipArchive(url: Fixture.url("WhatsApp Chat - Anna Rossi.zip"))
        #expect(archive.entries.map(\.path) == ["_chat.txt", "00000003-PHOTO-2024-03-14-09-31-10.jpg", "__MACOSX/._chat.txt"])
        #expect(archive.entries.map(\.isMetadata) == [false, false, true])
        #expect(archive.entries[0].method == .deflated)
    }

    @Test func rejectsAFileThatIsNotAnArchive() {
        #expect(throws: ZipError.notAnArchive) {
            try ZipArchive(url: Fixture.url("not-a-chat.txt"))
        }
    }

    @Test func detectsDamagedData() throws {
        let url = try Fixture.copy("WhatsApp Chat - Anna Rossi.zip")
        var bytes = try [UInt8](Data(contentsOf: url))
        // Flip a byte inside the first entry's compressed data, after its 30-byte header and name.
        bytes[30 + "_chat.txt".utf8.count + 20] ^= 0xFF
        try Data(bytes).write(to: url)

        let archive = try ZipArchive(url: url)
        #expect(throws: (any Error).self) {
            try archive.read(archive.entries[0]) { _ in }
        }
    }

    @Test func crcMatchesTheReferenceValue() {
        var crc = CRC32()
        crc.update(Data("123456789".utf8))
        #expect(crc.value == 0xCBF4_3926)
    }
}
