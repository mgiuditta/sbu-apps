import Foundation
import Testing
@testable import SbuChats

/// The export limit: about 40,000 messages. Import, numbers and search must stay quick on it.
struct LargeChatTests {
    private static func exportText(messages: Int) -> String {
        var lines: [String] = []
        lines.reserveCapacity(messages)
        let names = ["Anna", "Luca", "Marta", "Paolo", "Giulia", "Marco"]
        for index in 0 ..< messages {
            let day = index / 120
            let date = Calendar(identifier: .gregorian).date(byAdding: .day, value: day, to: Date(timeIntervalSince1970: 1_700_000_000)) ?? .now
            let parts = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: date)
            let slot = index % 120
            lines.append("[\(parts.day ?? 1)/\(parts.month ?? 1)/\((parts.year ?? 2024) % 100), \(8 + slot / 10):\(slot % 6)5:\(slot % 6)0] \(names[index % names.count]): messaggio numero \(index) con qualche parola in più 👍")
        }
        return lines.joined(separator: "\n")
    }

    @Test(.timeLimit(.minutes(1)))
    func fortyThousandMessagesImportCountAndSearch() async throws {
        let url = try Fixture.textFile(Self.exportText(messages: 40_000), name: "Gruppo.txt")
        let store = try ChatStore(url: nil)
        let started = ContinuousClock.now
        let outcome = try await store.importChat(from: url, knownOwners: ["Anna"])
        let imported = ContinuousClock.now - started
        #expect(outcome.addedMessages == 40_000)
        #expect(outcome.senders.count == 6)

        let stats = try await store.statistics(chatID: outcome.chatID, from: nil, to: nil, owner: "Anna")
        #expect(stats.totalMessages == 40_000)
        #expect(stats.senders.first?.name == "Anna")

        let search = try await store.search(chatID: outcome.chatID, for: "\"numero 39999\"")
        #expect(search.total == 1)

        let terms = try await store.terms(chatID: outcome.chatID, from: nil, to: nil)
        #expect(terms.emoji.first?.count == 40_000)

        // Generous for a debug build on a shared simulator; on a device it's a few seconds.
        #expect(imported < .seconds(30), "import took \(imported)")
    }
}
