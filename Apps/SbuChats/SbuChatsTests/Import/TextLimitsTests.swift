import Foundation
import Testing
@testable import SbuChats

/// Crafted texts: the line, message and total ceilings hold whatever the line endings.
struct TextLimitsTests {
    private func lines(_ text: String, chunkSize: Int = 3, maximumLineBytes: Int = 1024) throws -> [String] {
        var splitter = LineSplitter(maximumLineBytes: maximumLineBytes)
        var lines: [String] = []
        let bytes = Array(text.utf8)
        var index = 0
        while index < bytes.count {
            let end = min(index + chunkSize, bytes.count)
            try splitter.feed(Data(bytes[index ..< end])) { lines.append($0) }
            index = end
        }
        splitter.finish { lines.append($0) }
        return lines
    }

    @Test(arguments: [1, 2, 5])
    func aLoneCarriageReturnEndsALineAndCRLFIsOneBreak(chunkSize: Int) throws {
        #expect(try lines("a\rb\r\nc\n\rd", chunkSize: chunkSize) == ["a", "b", "c", "", "d"])
    }

    @Test(arguments: ["", "\n", "\r", "\r\n"])
    func aLineWithoutBreaksStopsAtTheCeiling(ending: String) {
        let text = String(repeating: "a", count: 100) + ending
        #expect(throws: ImportFailure.lineTooLong) {
            try lines(text, maximumLineBytes: 64)
        }
    }

    @Test func aLineAtTheCeilingPasses() throws {
        #expect(try lines(String(repeating: "a", count: 64) + "\n", maximumLineBytes: 64).first?.count == 64)
    }

    @Test func aTextFileOverTheTotalCeilingIsTooLarge() throws {
        let url = try Fixture.textFile(String(repeating: "[1/2/24, 10:00:00] Ada: ciao\n", count: 100))
        #expect(throws: ImportFailure.tooLarge) {
            try ChatTextSource(textFile: url, maximumTextBytes: 1000)
        }
    }

    @Test func aZipEntryOverTheTotalCeilingIsTooLarge() throws {
        let archive = try ZipArchive(url: Fixture.url("WhatsApp Chat - Anna Rossi.zip"))
        #expect(throws: ImportFailure.tooLarge) {
            try ChatTextSource(archive: archive, entry: archive.entries[0], maximumTextBytes: 100)
        }
    }

    @Test func endlessContinuationLinesStopAtTheMessageCeiling() throws {
        let text = "[1/2/24, 10:00:00] Ada: inizio\n" + String(repeating: "ancora una riga\n", count: 200)
        let source = try ChatTextSource(textFile: Fixture.textFile(text), maximumLineBytes: 256)
        #expect(throws: ImportFailure.lineTooLong) {
            _ = try WhatsAppParser().parse(source, progress: { _ in }) { _ in }
        }
    }

    @Test func aFileWithoutLineBreaksIsRefusedOnImport() async throws {
        let store = try ChatStore(url: nil)
        let url = try Fixture.textFile(String(repeating: "x", count: LineSplitter.defaultMaximumLineBytes + 10))
        await #expect(throws: ImportFailure.lineTooLong) {
            try await store.importChat(from: url, knownOwners: [])
        }
    }
}
