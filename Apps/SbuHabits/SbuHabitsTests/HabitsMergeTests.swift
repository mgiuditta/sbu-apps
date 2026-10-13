import Foundation
import Testing
@testable import SbuHabits

struct HabitsMergeTests {
    private static let start = LogicalDay(ordinal: 20_000)
    private static let monday = Date(timeIntervalSince1970: 1_760_000_000)
    private static let tuesday = monday.addingTimeInterval(86_400)
    private static let wednesday = tuesday.addingTimeInterval(86_400)

    private static func habit(_ title: String, id: UUID = UUID(), editedAt date: Date? = monday) -> Habit {
        var habit = Habit(id: id, title: title, symbol: "book", createdOn: start)
        habit.modifiedAt = date
        return habit
    }

    private static func merge(_ local: HabitsFile, _ remote: HabitsFile, base: HabitsFile? = nil, now: Date = wednesday) -> HabitsFile {
        HabitsMerge.merge(local, remote, base: base, now: now)
    }

    // MARK: - Habits on one side

    @Test func habitsCreatedApartStayTwoEvenWithTheSameTitle() {
        let here = HabitsFile(habits: [Self.habit("Leggere")])
        let there = HabitsFile(habits: [Self.habit("Leggere")])

        let merged = Self.merge(here, there)

        #expect(merged.habits.count == 2)
        #expect(Set(merged.habits.map(\.id)) == Set(here.habits.map(\.id) + there.habits.map(\.id)))
    }

    @Test func turningSyncOnWithAnEmptyICloudKeepsEverything() {
        var reading = Self.habit("Leggere")
        reading.mark(on: Self.start, hour: 9)
        reading.toggleSkip(on: Self.start + 1)
        reading.setNote("Bene", on: Self.start, at: Self.monday)
        let here = HabitsFile(habits: [reading], startHour: 3)

        #expect(Self.merge(here, HabitsFile()) == here)
    }

    @Test func mergingAFileWithItselfChangesNothing() {
        var reading = Self.habit("Leggere")
        reading.mark(on: Self.start, hour: 9)
        let file = HabitsFile(habits: [reading, Self.habit("Camminare")], startHour: 2, deleted: [UUID(): Self.tuesday], orderModifiedAt: Self.monday)

        #expect(Self.merge(file, file, base: file) == file)
        #expect(Self.merge(file, file) == file)
    }

    // MARK: - Marks and skips

    @Test func theSameDayKeepsTheHigherCountWithItsHours() throws {
        let id = UUID()
        var here = Self.habit("Acqua", id: id)
        _ = here.update(title: "Acqua", symbol: "drop", timesPerDay: 8, schedule: .everyDay, from: Self.start)
        var there = here
        for hour in [8, 9] { here.mark(on: Self.start, hour: hour) }
        for hour in [10, 11, 12] { there.mark(on: Self.start, hour: hour) }

        let merged = try #require(Self.merge(HabitsFile(habits: [here]), HabitsFile(habits: [there])).habits.first)

        #expect(merged.count(on: Self.start) == 3)
        #expect(merged.markHours[Self.start] == [10, 11, 12])
    }

    @Test func aSkipOnEitherIPhoneWins() throws {
        let id = UUID()
        var here = Self.habit("Leggere", id: id)
        var there = here
        here.toggleSkip(on: Self.start)
        there.mark(on: Self.start, hour: 9)

        let merged = try #require(Self.merge(HabitsFile(habits: [here]), HabitsFile(habits: [there])).habits.first)

        #expect(merged.isSkipped(on: Self.start))
        #expect(merged.count(on: Self.start) == 0)
    }

    @Test func aMarkTakenBackAfterASyncStaysTakenBack() throws {
        var synced = Self.habit("Acqua")
        _ = synced.update(title: "Acqua", symbol: "drop", timesPerDay: 8, schedule: .everyDay, from: Self.start)
        synced.mark(on: Self.start, hour: 8)
        synced.mark(on: Self.start, hour: 9)
        var here = synced
        here.undoLast(on: Self.start)
        let base = HabitsFile(habits: [synced])

        let merged = try #require(Self.merge(HabitsFile(habits: [here]), base, base: base).habits.first)

        #expect(merged.count(on: Self.start) == 1)
        #expect(merged.markHours[Self.start] == [8])
    }

    @Test func daysChangedOnEachIPhoneAllArrive() throws {
        let synced = Self.habit("Leggere")
        var here = synced
        var there = synced
        here.mark(on: Self.start, hour: 9)
        there.mark(on: Self.start + 1, hour: 21)
        there.toggleSkip(on: Self.start + 2)

        let merged = try #require(Self.merge(HabitsFile(habits: [here]), HabitsFile(habits: [there]), base: HabitsFile(habits: [synced])).habits.first)

        #expect(merged.isDone(on: Self.start))
        #expect(merged.isDone(on: Self.start + 1))
        #expect(merged.isSkipped(on: Self.start + 2))
    }

    // MARK: - Settings

    @Test(arguments: [true, false])
    func theNewerEditOfTheSettingsWins(isNewerHere: Bool) throws {
        let id = UUID()
        var here = Self.habit("Leggere", id: id, editedAt: isNewerHere ? Self.tuesday : Self.monday)
        var there = Self.habit("Leggere libri", id: id, editedAt: isNewerHere ? Self.monday : Self.tuesday)
        _ = here.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .weekdays([2, 4]), reminders: [ReminderTime(hour: 21, minute: 0)], notificationStyle: NotificationStyle(isTimeSensitive: true), from: Self.start + 3)
        _ = there.update(title: "Leggere libri", symbol: "books.vertical", timesPerDay: 1, schedule: .everyDay, timerMinutes: 20, from: Self.start)
        here.mark(on: Self.start, hour: 9)
        there.mark(on: Self.start + 1, hour: 9)

        let merged = try #require(Self.merge(HabitsFile(habits: [here]), HabitsFile(habits: [there])).habits.first)
        let winner = isNewerHere ? here : there

        #expect(merged.settingsOnly == winner.settingsOnly)
        #expect(merged.title == winner.title)
        #expect(merged.schedule(on: Self.start) == winner.schedule(on: Self.start))
        #expect(merged.reminders == winner.reminders)
        #expect(merged.timerMinutes == winner.timerMinutes)
        // Marks are merged apart from the settings: both days stay.
        #expect(merged.isDone(on: Self.start) && merged.isDone(on: Self.start + 1))
    }

    @Test func settingsWithoutDatesPickTheSameSideOnBothIPhones() {
        let id = UUID()
        let here = HabitsFile(habits: [Self.habit("Leggere", id: id, editedAt: nil)])
        let there = HabitsFile(habits: [Self.habit("Lettura", id: id, editedAt: nil)])

        #expect(Self.merge(here, there) == Self.merge(there, here))
    }

    // MARK: - Notes

    @Test(arguments: [true, false])
    func theNewerNoteWins(isNewerHere: Bool) throws {
        let id = UUID()
        var here = Self.habit("Leggere", id: id)
        var there = here
        here.setNote("Venti pagine", on: Self.start, at: isNewerHere ? Self.tuesday : Self.monday)
        there.setNote("Trenta pagine", on: Self.start, at: isNewerHere ? Self.monday : Self.tuesday)

        let merged = try #require(Self.merge(HabitsFile(habits: [here]), HabitsFile(habits: [there])).habits.first)

        #expect(merged.note(on: Self.start) == (isNewerHere ? "Venti pagine" : "Trenta pagine"))
    }

    @Test func aNoteClearedLaterStaysCleared() throws {
        let id = UUID()
        var here = Self.habit("Leggere", id: id)
        var there = here
        here.setNote("Venti pagine", on: Self.start, at: Self.monday)
        there.setNote("Venti pagine", on: Self.start, at: Self.monday)
        there.setNote("", on: Self.start, at: Self.tuesday)

        let merged = try #require(Self.merge(HabitsFile(habits: [here]), HabitsFile(habits: [there])).habits.first)

        #expect(merged.note(on: Self.start) == nil)
    }

    // MARK: - Deletions

    @Test(arguments: [true, false])
    func aDeletionWinsEvenOverALaterEdit(isDeletedHere: Bool) {
        let id = UUID()
        var edited = Self.habit("Leggere", id: id, editedAt: Self.wednesday)
        edited.mark(on: Self.start, hour: 9)
        let deleting = HabitsFile(habits: [], deleted: [id: Self.monday])
        let editing = HabitsFile(habits: [edited])

        let merged = isDeletedHere ? Self.merge(deleting, editing) : Self.merge(editing, deleting)

        #expect(merged.habits.isEmpty)
        #expect(merged.deleted[id] == Self.monday)
    }

    @Test func deletionsAreForgottenAfterAYear() {
        let recent = UUID()
        let old = UUID()
        let file = HabitsFile(deleted: [recent: Self.monday, old: Self.monday.addingTimeInterval(-HabitsFile.deletionMemory - 1)])

        let merged = Self.merge(file, HabitsFile(), now: Self.monday)

        #expect(merged.deleted.keys.sorted { $0.uuidString < $1.uuidString } == [recent])
    }

    @Test func aHabitDeletedOverAYearAgoIsStillDroppedInThatMerge() {
        let id = UUID()
        let file = HabitsFile(deleted: [id: Self.monday.addingTimeInterval(-HabitsFile.deletionMemory - 1)])

        let merged = Self.merge(file, HabitsFile(habits: [Self.habit("Leggere", id: id)]), now: Self.monday)

        #expect(merged.habits.isEmpty)
        #expect(merged.deleted.isEmpty)
    }

    // MARK: - Order and start of the day

    @Test(arguments: [true, false])
    func theNewerOrderWinsAndNewHabitsGoLast(isNewerHere: Bool) {
        let first = Self.habit("Uno")
        let second = Self.habit("Due")
        let added = Self.habit("Nuova")
        let here = HabitsFile(habits: [first, second], orderModifiedAt: isNewerHere ? Self.tuesday : Self.monday)
        let there = HabitsFile(habits: [second, added, first], orderModifiedAt: isNewerHere ? Self.monday : Self.tuesday)

        let merged = Self.merge(here, there)

        #expect(merged.habits.map(\.title) == (isNewerHere ? ["Uno", "Due", "Nuova"] : ["Due", "Nuova", "Uno"]))
        #expect(merged.orderModifiedAt == Self.tuesday)
    }

    @Test(arguments: [true, false])
    func theNewerStartOfTheDayWins(isNewerHere: Bool) {
        let here = HabitsFile(startHour: 4, startHourModifiedAt: isNewerHere ? Self.tuesday : Self.monday)
        let there = HabitsFile(startHour: 2, startHourModifiedAt: isNewerHere ? Self.monday : Self.tuesday)

        let merged = Self.merge(here, there)

        #expect(merged.startHour == (isNewerHere ? 4 : 2))
        #expect(merged.startHourModifiedAt == Self.tuesday)
    }

    // MARK: - Agreement

    /// Two iPhones merging the same pair in opposite roles must end with the same file.
    @Test(arguments: 0..<4)
    func bothIPhonesEndWithTheSameFile(seed: Int) {
        let shared = Self.habit("Leggere")
        var here = shared
        var there = shared
        here.mark(on: Self.start + seed, hour: 9)
        there.toggleSkip(on: Self.start + seed)
        there.mark(on: Self.start + 1, hour: 10)
        here.setNote("Qui", on: Self.start, at: Self.monday)
        there.setNote("Là", on: Self.start, at: seed.isMultiple(of: 2) ? Self.monday : Self.tuesday)
        let local = HabitsFile(habits: [here, Self.habit("Solo qui")], startHour: seed, startHourModifiedAt: Self.monday)
        let remote = HabitsFile(habits: [Self.habit("Solo là"), there], startHour: 1, deleted: [UUID(): Self.monday], startHourModifiedAt: Self.monday)
        let base = HabitsFile(habits: [shared])

        #expect(Self.merge(local, remote) == Self.merge(remote, local))
        #expect(Self.merge(local, remote, base: base) == Self.merge(remote, local, base: base))
    }
}
