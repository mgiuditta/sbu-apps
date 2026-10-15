import Foundation
import Testing
@testable import SbuChats

struct LineSplitterTests {
    private func lines(of bytes: [UInt8], chunkSize: Int) -> [String] {
        var splitter = LineSplitter()
        var lines: [String] = []
        var index = 0
        while index < bytes.count {
            let end = min(index + chunkSize, bytes.count)
            splitter.feed(Data(bytes[index ..< end])) { lines.append($0) }
            index = end
        }
        splitter.finish { lines.append($0) }
        return lines
    }

    @Test(arguments: [1, 2, 3, 7, 4096])
    func splitsTheSameWhateverTheChunkSize(chunkSize: Int) {
        let text = "\u{FEFF}[1/2/24, 10:00] Anna: è già qui 👍🏽\r\nseconda riga\nterza"
        #expect(lines(of: Array(text.utf8), chunkSize: chunkSize) == ["[1/2/24, 10:00] Anna: è già qui 👍🏽", "seconda riga", "terza"])
    }

    @Test func keepsEmptyLinesInsideAMessage() {
        #expect(lines(of: Array("a\n\nb\n".utf8), chunkSize: 2) == ["a", "", "b"])
    }

    @Test func repairsInvalidUTF8() {
        let result = lines(of: [0x61, 0xFF, 0x62, 0x0A], chunkSize: 10)
        #expect(result == ["a\u{FFFD}b"])
    }
}
