import Foundation
import Testing
@testable import SbuSquares

struct ShareTextTests {
    @Test func theSharedTextEndsWithTheBoardAndTheLink() {
        let text = ShareText.make(for: Game(seed: 1, recordToBeat: 0))
        let lines = text.split(separator: "\n")
        #expect(lines.first == "Sbu Squares")
        #expect(lines.dropFirst(2).prefix(8).allSatisfy { $0 == "□□□□□□□□" })
        #expect(lines.last == "sbu.dev/games/squares")
    }
}
