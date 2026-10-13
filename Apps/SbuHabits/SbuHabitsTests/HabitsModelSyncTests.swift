import Foundation
import Testing
@testable import SbuHabits

/// The dates and deletions the model keeps for Sincronizza con iCloud, sync on or off.
struct HabitsModelSyncTests {
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "HabitsModelSyncTests-\(UUID().uuidString).json"))
    private let clock = TestClock(Date(timeIntervalSince1970: 1_760_000_000))

    private func model() -> HabitsModel {
        HabitsModel(store: store, now: { [clock] in clock.now }, scheduleReminders: { _ in })
    }

    @Test func addingAndEditingDateTheSettings() throws {
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        #expect(model.habits[0].modifiedAt == clock.now)

        clock.advance(by: 60)
        model.edit(model.habits[0], title: "Leggere libri", symbol: "book", timesPerDay: 1, schedule: .everyDay)

        #expect(model.habits[0].modifiedAt == clock.now)
        #expect(try store.load().habits[0].modifiedAt == clock.now)
    }

    @Test func marksAndSkipsLeaveTheSettingsDateAlone() {
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        let added = clock.now
        clock.advance(by: 60)

        model.markDone(model.habits[0])
        model.toggleSkip(model.habits[0])

        #expect(model.habits[0].modifiedAt == added)
    }

    @Test func aBlankEditChangesNothingNotEvenTheDate() {
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        let added = clock.now
        clock.advance(by: 60)

        model.edit(model.habits[0], title: "  ", symbol: "book", timesPerDay: 1, schedule: .everyDay)

        #expect(model.habits[0].modifiedAt == added)
    }

    @Test func aNoteKeepsTheTimeItWasWrittenAndCleared() {
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        model.setNote("Venti pagine", for: model.habits[0], on: model.today)
        #expect(model.habits[0].noteDates[model.today] == clock.now)

        clock.advance(by: 60)
        model.setNote("", for: model.habits[0], on: model.today)

        #expect(model.habits[0].note(on: model.today) == nil)
        #expect(model.habits[0].noteDates[model.today] == clock.now)
    }

    @Test func aDeletedHabitIsRemembered() throws {
        let model = model()
        model.add(title: "Leggere", symbol: "book")
        let id = model.habits[0].id

        model.delete(model.habits[0])

        #expect(model.deleted[id] == clock.now)
        #expect(try store.load().deleted[id] == clock.now)
    }

    @Test func reorderingAndTheStartOfTheDayAreDated() {
        let model = model()
        model.add(title: "Uno", symbol: "book")
        model.add(title: "Due", symbol: "book")

        model.move(fromOffsets: [1], toOffset: 0)
        model.setStartHour(4)

        #expect(model.orderModifiedAt == clock.now)
        #expect(model.startHourModifiedAt == clock.now)
    }

    @Test func aMergedFileIsSavedForTheWidget() throws {
        let model = model()
        let habit = Habit(title: "Camminare", symbol: "figure.walk", createdOn: model.today)

        model.applySynced(HabitsFile(habits: [habit], startHour: 3))

        #expect(model.habits == [habit])
        #expect(model.startHour == 3)
        #expect(try store.load().habits == [habit])
    }

    @Test func aMergeThatDeletesTheTimedHabitStopsItsTimer() throws {
        let timers = HabitTimerStore(defaults: .standard, key: "HabitsModelSyncTests-\(UUID().uuidString)")
        let model = HabitsModel(store: store, now: { [clock] in clock.now }, scheduleReminders: { _ in }, timerStore: timers)
        model.add(title: "Leggere", symbol: "book", timerMinutes: 10)
        model.startTimer(for: model.habits[0])
        #expect(model.timer != nil)

        model.applySynced(HabitsFile(deleted: [model.habits[0].id: clock.now]))

        #expect(model.timer == nil)
        timers.save(nil)
    }
}
