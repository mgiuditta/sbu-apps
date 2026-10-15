import Foundation
import Testing
@testable import SbuChats

struct SampleChatTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? .gmt
        return calendar
    }()

    private static let end = Date(timeIntervalSince1970: 1_760_000_000)

    @Test(arguments: [SampleChat.Language.italian, .english])
    func isTheSameEveryTime(language: SampleChat.Language) {
        #expect(SampleChat.text(language, endingBefore: Self.end, calendar: Self.calendar)
            == SampleChat.text(language, endingBefore: Self.end, calendar: Self.calendar))
    }

    @Test(arguments: [SampleChat.Language.italian, .english])
    func importsAsATwoPersonChatOfAboutAYear(language: SampleChat.Language) async throws {
        let url = try Fixture.textFile(SampleChat.text(language, endingBefore: Self.end, calendar: Self.calendar), name: SampleChat.fileName(language))
        let store = try ChatStore(url: nil)
        let outcome = try await store.importChat(from: url, knownOwners: [SampleChat.owner(language)])
        #expect(Set(outcome.senders) == [SampleChat.owner(language), SampleChat.other(language)])
        #expect(!outcome.needsOwner)

        let chat = try #require(try await store.chat(id: outcome.chatID))
        #expect(chat.title == (language == .italian ? "Chat di esempio" : "Sample chat"))
        #expect(chat.messageCount > 2_000)
        let days = chat.lastMessageAt.timeIntervalSince(chat.firstMessageAt) / 86400
        #expect(days > 400)

        let stats = try await store.statistics(chatID: chat.id, from: nil, to: nil, owner: chat.owner, calendar: Self.calendar)
        let you = try #require(stats.senders.first)
        #expect(you.isOwner)
        #expect(you.media > 0)
        #expect(you.medianReply != nil)
    }
}
