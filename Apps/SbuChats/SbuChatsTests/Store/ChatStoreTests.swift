import Foundation
import Testing
@testable import SbuChats

struct ChatStoreTests {
    private let store: ChatStore

    init() throws {
        store = try ChatStore(url: nil)
    }

    @Test func importsAZipWithMediaAsOneChat() async throws {
        let outcome = try await store.importChat(from: Fixture.url("WhatsApp Chat - Anna Rossi.zip"), knownOwners: [])
        #expect(outcome.addedMessages == 9) // eleven lines, two of them system
        #expect(!outcome.merged)
        #expect(outcome.needsOwner)
        #expect(Set(outcome.senders) == ["Anna Rossi", "Luca Bianchi"])

        let chat = try #require(try await store.chat(id: outcome.chatID))
        #expect(chat.title == "Anna Rossi")
        #expect(chat.messageCount == 9)
        #expect(chat.hasMedia)
        #expect(chat.sourceFormat == "ios")
    }

    @Test func aNewerExportAddsOnlyTheNewMessages() async throws {
        let first = try await store.importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: [])
        let newer = try await store.importChat(from: Fixture.copy("ios-it-24h-newer.txt", as: "WhatsApp Chat - Anna Rossi.txt"), knownOwners: [])
        #expect(newer.merged)
        #expect(newer.chatID == first.chatID)
        #expect(newer.addedMessages == 3) // two identical "Volentieri" in the same minute stay two
        #expect(try await store.chats().count == 1)
        #expect(try await store.chat(id: first.chatID)?.messageCount == 12)

        // The same file again adds nothing.
        let again = try await store.importChat(from: Fixture.url("ios-it-24h-newer.txt"), knownOwners: [])
        #expect(again.merged)
        #expect(again.addedMessages == 0)
    }

    @Test func aDifferentChatStaysApart() async throws {
        _ = try await store.importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: [])
        let other = try await store.importChat(from: Fixture.url("android-it-24h.txt"), knownOwners: [])
        #expect(!other.merged)
        #expect(try await store.chats().count == 2)
    }

    @Test func aNameYouGaveBeforeAnswersWhoYouAre() async throws {
        let outcome = try await store.importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: ["Luca Bianchi", "Someone Else"])
        #expect(!outcome.needsOwner)
        #expect(try await store.chat(id: outcome.chatID)?.owner == "Luca Bianchi")
    }

    @Test func remembersTheOwnerAcrossAMerge() async throws {
        let first = try await store.importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: [])
        try await store.setOwner(chatID: first.chatID, sender: "Anna Rossi")
        let newer = try await store.importChat(from: Fixture.url("ios-it-24h-newer.txt"), knownOwners: [])
        #expect(!newer.needsOwner)
        #expect(try await store.chat(id: first.chatID)?.owner == "Anna Rossi")
    }

    @Test func searchFindsWordsPhrasesAndAlternatives() async throws {
        let chat = try await store.importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: []).chatID
        #expect(try await store.search(chatID: chat, for: "vino").total == 1)
        #expect(try await store.search(chatID: chat, for: "buongiorno").total == 2)
        #expect(try await store.search(chatID: chat, for: "buon").total == 2) // start of a word
        #expect(try await store.search(chatID: chat, for: "\"solito posto\"").total == 1)
        #expect(try await store.search(chatID: chat, for: "\"posto solito\"").total == 0)
        #expect(try await store.search(chatID: chat, for: "vino OR pane").total == 2)
        #expect(try await store.search(chatID: chat, for: "buongiorno", sender: "Luca Bianchi").total == 1)
        #expect(try await store.search(chatID: chat, for: "perche").total == 0)
        #expect(try await store.search(chatID: chat, for: "si").total == 1) // "Sì" without its accent

        let hit = try #require(try await store.search(chatID: chat, for: "vino").hits.first)
        #expect(hit.sender == "Luca Bianchi")
        #expect(hit.snippet.contains("\u{1}vino\u{2}"))
    }

    @Test func searchNeverFailsOnPunctuation() async throws {
        let chat = try await store.importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: []).chatID
        for input in ["\"", "*", "OR", "a AND", "(vino", "-", "NEAR(", "vino\""] {
            _ = try await store.search(chatID: chat, for: input)
        }
    }

    @Test func deletingAChatRemovesItsMessagesAndIndex() async throws {
        let chat = try await store.importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: []).chatID
        try await store.delete(chatID: chat)
        #expect(try await store.chats().isEmpty)
        #expect(try await store.records(chatID: chat).isEmpty)
        #expect(try await store.search(chatID: chat, for: "vino").total == 0)
    }

    @Test func renamesAChat() async throws {
        let chat = try await store.importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: []).chatID
        try await store.rename(chatID: chat, title: "Anna")
        #expect(try await store.chat(id: chat)?.title == "Anna")
    }

    @Test(arguments: [
        ("not-a-chat.txt", ImportFailure.unrecognizedFormat(firstLine: "Lista della spesa")),
        ("photos-only.zip", .noChatInArchive),
    ])
    func explainsWhyAFileIsNotAChat(name: String, failure: ImportFailure) async throws {
        await #expect(throws: failure) {
            try await store.importChat(from: Fixture.url(name), knownOwners: [])
        }
        #expect(try await store.chats().isEmpty)
    }

    @Test func refusesOtherFileTypes() async throws {
        let url = try Fixture.copy("not-a-chat.txt", as: "photo.jpg")
        await #expect(throws: ImportFailure.unsupportedFile(fileExtension: "jpg")) {
            try await store.importChat(from: url, knownOwners: [])
        }
    }

    @Test func aDamagedZipSaysSo() async throws {
        let url = try Fixture.copy("WhatsApp Chat - Anna Rossi.zip")
        let data = try Data(contentsOf: url)
        try data.prefix(data.count / 2).write(to: url)
        await #expect(throws: ImportFailure.damagedArchive) {
            try await store.importChat(from: url, knownOwners: [])
        }
    }

    @Test func persistsAcrossLaunches() async throws {
        let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString)/chats.sqlite")
        let chat = try await ChatStore(url: url).importChat(from: Fixture.url("ios-it-24h.txt"), knownOwners: []).chatID
        let reopened = try ChatStore(url: url)
        #expect(try await reopened.chat(id: chat)?.messageCount == 9)
    }
}
