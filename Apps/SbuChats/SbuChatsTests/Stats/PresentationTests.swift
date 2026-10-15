import Foundation
import Testing
@testable import SbuChats

struct PresentationTests {
    @Test func snippetMarksBecomeBold() {
        let text = SearchSnippet.attributed("Porto io il \u{1}vino\u{2} e il \u{1}pane\u{2}")
        #expect(String(text.characters) == "Porto io il vino e il pane")
        let bold = text.runs.filter { $0.inlinePresentationIntent == .stronglyEmphasized }.map { String(text[$0.range].characters) }
        #expect(bold == ["vino", "pane"])
    }

    @Test(arguments: [(45.0, "45"), (180.0, "3"), (4_800.0, "1"), (0.4, "0")])
    func replyTimesKeepTheLargestUnits(interval: Double, leadingNumber: String) {
        let text = ReplyTime.text(interval)
        #expect(text.hasPrefix(leadingNumber))
        #expect(!text.contains("-"))
    }

    @Test func capitalizesOnlyTheFirstLetter() {
        #expect("alle 21".capitalizedFirst == "Alle 21")
        #expect("".capitalizedFirst == "")
    }
}
