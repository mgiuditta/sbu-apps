import Testing
@testable import SbuChats

struct TermStatisticsTests {
    @Test func ranksWordsWithoutStopwordsLinksOrNumbers() {
        let stats = TermStatistics(texts: [
            SenderText(sender: "Anna", text: "Ci vediamo stasera per la pizza, la pizza è buona"),
            SenderText(sender: "Luca", text: "Pizza! Alle 20 https://example.com"),
            SenderText(sender: "Luca", text: "Va bene, ci vediamo dopo"),
        ])
        #expect(stats.words.first == RankedTerm(term: "pizza", count: 3))
        #expect(stats.words.contains(RankedTerm(term: "vediamo", count: 2)))
        let terms = Set(stats.words.map(\.term))
        #expect(!terms.contains("la"))
        #expect(!terms.contains("ci"))
        #expect(!terms.contains("20"))
        #expect(!terms.contains { $0.contains("example") || $0.contains("http") })
        #expect(stats.wordsBySender["Luca"]?.contains(RankedTerm(term: "pizza", count: 1)) == true)
    }

    @Test func italianElisionsCountTheWordAfterTheApostrophe() {
        let stats = TermStatistics(texts: [
            SenderText(sender: "Anna", text: "Esco ora dall'ufficio, poi passo all'ufficio postale e dall’ufficio di Marco"),
            SenderText(sender: "Luca", text: "Va bene, ci vediamo dopo l'ufficio, l'amore mio"),
        ])
        #expect(stats.words.first == RankedTerm(term: "ufficio", count: 4))
        #expect(!stats.words.contains { $0.term.contains("'") || $0.term.contains("’") })
    }

    @Test func countsEmojiAsPeopleSeeThem() {
        let stats = TermStatistics(texts: [
            SenderText(sender: "Anna", text: "👍🏽👍🏽 👍 ok"),
            SenderText(sender: "Luca", text: "👨‍👩‍👧 🇮🇹 ❤️ 1 # © 2️⃣"),
        ])
        #expect(stats.emoji.first == RankedTerm(term: "👍🏽", count: 2))
        let emoji = Set(stats.emoji.map(\.term))
        #expect(emoji == ["👍🏽", "👍", "👨‍👩‍👧", "🇮🇹", "❤️", "2️⃣"])
        #expect(stats.emojiBySender["Luca"]?.count == 4)
    }

    @Test func anEmptyChatHasNoTerms() {
        #expect(TermStatistics.empty.words.isEmpty)
        #expect(TermStatistics.empty.emoji.isEmpty)
    }
}
