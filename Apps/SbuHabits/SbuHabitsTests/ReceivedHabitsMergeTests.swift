import Foundation
import Testing
@testable import SbuHabits

/// How a refresh changes the Abitudini condivise received.
struct ReceivedHabitsMergeTests {
    private let today = LogicalDay(ordinal: 20_010)

    private func snapshot(_ title: String, marks: Int = 0) -> SharedHabitSnapshot {
        var habit = Habit(id: UUID(uuidString: "00000000-0000-0000-0000-00000000000\(title.count % 10)") ?? UUID(), title: title, symbol: "book", createdOn: today - 10)
        for offset in 0..<marks {
            habit.mark(on: today - offset, hour: 8)
        }
        return SharedHabitSnapshot(habit: habit, startHour: 0)
    }

    private func received(_ key: String, _ title: String, emoji: String? = nil) -> ReceivedHabit {
        ReceivedHabit(key: key, snapshot: snapshot(title), ownerEmoji: emoji)
    }

    @Test func aNewShareGoesLast() {
        let file = ReceivedHabitsFile(habits: [received("a", "Leggere")])

        let merged = ReceivedHabitsMerge.merge(file, with: [FetchedShare(key: "b", snapshot: snapshot("Correre")), FetchedShare(key: "a", snapshot: snapshot("Leggere"))])

        #expect(merged.habits.map(\.key) == ["a", "b"])
    }

    @Test func anUpdateReplacesTheCopyAndKeepsTheEmoji() {
        let file = ReceivedHabitsFile(habits: [received("a", "Leggere", emoji: "😎")])
        let updated = snapshot("Leggere", marks: 3)

        let merged = ReceivedHabitsMerge.merge(file, with: [FetchedShare(key: "a", snapshot: updated)])

        #expect(merged.habits.first?.snapshot == updated)
        #expect(merged.habits.first?.ownerEmoji == "😎")
    }

    @Test(arguments: [true, false])
    func aShareNoLongerListedIsGone(wasRead: Bool) {
        let file = ReceivedHabitsFile(habits: [received("a", "Leggere"), received("b", "Correre")])

        let merged = ReceivedHabitsMerge.merge(file, with: [FetchedShare(key: "b", snapshot: wasRead ? snapshot("Correre") : nil)])

        #expect(merged.habits.map(\.key) == ["b"])
    }

    @Test func aShareThatCannotBeReadKeepsItsCopy() {
        let file = ReceivedHabitsFile(habits: [received("a", "Leggere")])

        let merged = ReceivedHabitsMerge.merge(file, with: [FetchedShare(key: "a", snapshot: nil)])

        #expect(merged.habits == file.habits)
    }

    @Test func aNewShareThatCannotBeReadWaits() {
        let merged = ReceivedHabitsMerge.merge(ReceivedHabitsFile(), with: [FetchedShare(key: "a", snapshot: nil)])

        #expect(merged.habits.isEmpty)
    }

    @Test(arguments: [true, false])
    func aRemovedShareStaysHiddenUntilICloudForgetsIt(isStillListed: Bool) {
        var file = ReceivedHabitsFile()
        file.removed = ["a"]
        let fetched = isStillListed ? [FetchedShare(key: "a", snapshot: snapshot("Leggere"))] : []

        let merged = ReceivedHabitsMerge.merge(file, with: fetched)

        #expect(merged.habits.isEmpty)
        #expect(merged.removed == (isStillListed ? ["a"] : []))
    }

    @Test func nothingListedEmptiesTheList() {
        let file = ReceivedHabitsFile(habits: [received("a", "Leggere")])

        #expect(ReceivedHabitsMerge.merge(file, with: []).habits.isEmpty)
    }
}
