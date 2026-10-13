import Foundation
import Testing
@testable import SbuHabits

/// The Abitudini condivise received, against shares in memory: no iCloud needed.
struct ReceivedHabitsTests {
    private let folder = URL.temporaryDirectory.appending(path: "ReceivedHabitsTests-\(UUID().uuidString)")
    private let today = LogicalDay(ordinal: 20_010)

    private var store: ReceivedHabitsStore {
        ReceivedHabitsStore(url: folder.appending(path: "received.json"))
    }

    private func snapshot(_ title: String, marks: Int = 0) -> SharedHabitSnapshot {
        var habit = Habit(title: title, symbol: "book", createdOn: today - 10)
        for offset in 0..<marks {
            habit.mark(on: today - offset, hour: 8)
        }
        return SharedHabitSnapshot(habit: habit, startHour: 0)
    }

    @Test func aRefreshShowsTheSharesAndSavesThemApart() async throws {
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        let received = ReceivedHabits(store: store, inbox: inbox)

        await received.refresh()

        #expect(received.habits.map(\.habit.title) == ["Correre"])
        #expect(try store.load().habits == received.habits)
        // Never in the user's own habits.
        #expect(store.url.lastPathComponent != "habits.json")
    }

    @Test func theOwnersChangesArriveAtTheNextRefresh() async {
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        let received = ReceivedHabits(store: store, inbox: inbox)
        await received.refresh()

        await inbox.put("a", snapshot("Correre", marks: 2))
        await received.refresh()

        #expect(received.habits.first?.habit.log.count == 2)
    }

    @Test func whenTheOwnerStopsSharingItDisappears() async {
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        let received = ReceivedHabits(store: store, inbox: inbox)
        await received.refresh()

        await inbox.drop("a")
        await received.refresh()

        #expect(received.habits.isEmpty)
    }

    @Test func offlineNothingChanges() async {
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        let received = ReceivedHabits(store: store, inbox: inbox)
        await received.refresh()

        await inbox.setOffline(true)
        await received.refresh()

        #expect(received.habits.count == 1)
    }

    @Test func theOwnersEmojiStaysHereAndSurvivesARefresh() async throws {
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        let received = ReceivedHabits(store: store, inbox: inbox)
        await received.refresh()

        received.setOwnerEmoji("🥳", for: received.habits[0])
        await inbox.put("a", snapshot("Correre", marks: 1))
        await received.refresh()

        #expect(received.habits.first?.ownerEmoji == "🥳")
        #expect(try store.load().habits.first?.ownerEmoji == "🥳")
    }

    @Test(arguments: [nil, "🐙"] as [String?])
    func anEmojiNotOfferedFallsBackToThePerson(emoji: String?) async {
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        let received = ReceivedHabits(store: store, inbox: inbox)
        await received.refresh()
        received.setOwnerEmoji("😎", for: received.habits[0])

        received.setOwnerEmoji(emoji, for: received.habits[0])

        #expect(received.habits.first?.ownerEmoji == nil)
    }

    @Test func removingLeavesTheShare() async {
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        await inbox.put("b", snapshot("Leggere"))
        let received = ReceivedHabits(store: store, inbox: inbox)
        await received.refresh()

        await received.remove(received.habits[0])
        await received.refresh()

        #expect(await inbox.left == ["a"])
        #expect(received.habits.map(\.key) == ["b"])
    }

    @Test func aRemovalICloudMissedStaysHiddenAndIsTriedAgain() async throws {
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        let received = ReceivedHabits(store: store, inbox: inbox)
        await received.refresh()
        await inbox.setFailsToLeave(true)

        await received.remove(received.habits[0])
        await received.refresh()
        #expect(received.habits.isEmpty)
        #expect(try store.load().removed == ["a"])

        await inbox.setFailsToLeave(false)
        await received.refresh()

        #expect(await inbox.left == ["a"])
        #expect(received.habits.isEmpty)
        #expect(try store.load().removed.isEmpty)
    }

    @Test(arguments: [true, false])
    func itSubscribesOnceWhenRemembered(remembers: Bool) async {
        let inbox = FakeInbox()
        let preferences = remembers ? UserDefaults(suiteName: "ReceivedHabitsTests-\(UUID().uuidString)") : nil
        let received = ReceivedHabits(store: store, inbox: inbox, preferences: preferences)

        await received.refresh()
        await received.refresh()

        #expect(await inbox.subscriptions == (remembers ? 1 : 2))
    }

    @Test func withoutAnInboxTheFileIsShownAsItIs() throws {
        try store.save(.demo(today: today))

        let received = ReceivedHabits(store: store, inbox: nil)

        #expect(received.habits.map(\.habit.title) == ["Correre"])
    }

    @Test func aFileFromANewerAppIsNeverOverwritten() async throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let newer = Data(#"{"version": 99, "habits": [], "removed": []}"#.utf8)
        try newer.write(to: store.url)
        let inbox = FakeInbox()
        await inbox.put("a", snapshot("Correre"))
        let received = ReceivedHabits(store: store, inbox: inbox)

        await received.refresh()

        #expect(received.habits.isEmpty)
        #expect(try Data(contentsOf: store.url) == newer)
    }
}
