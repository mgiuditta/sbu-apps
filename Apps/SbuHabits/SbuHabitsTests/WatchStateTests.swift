import Foundation
import Testing
@testable import SbuHabits

struct WatchStateTests {
    private let today = LogicalDay(ordinal: 1_004)
    private let reading: Habit
    private let water: Habit

    init() {
        reading = Habit(title: "Leggere", symbol: "book", createdOn: today - 10)
        water = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: today - 10)
    }

    private func snapshot(_ habits: [Habit], on day: LogicalDay? = nil, applied: [UUID] = []) -> WatchSnapshot {
        WatchSnapshot(habits: habits, today: day ?? today, startHour: 0, firstWeekday: 2, nextDayStart: .distantFuture, applied: applied)
    }

    private func mark(_ habit: Habit, on day: LogicalDay? = nil) -> WatchAction {
        WatchAction(habitID: habit.id, day: day ?? today, hour: 9, kind: .mark)
    }

    @Test func nothingShowsBeforeTheFirstGrid() {
        var state = WatchState()
        state.add(mark(reading))

        #expect(state.shown == nil)
    }

    @Test func aTapShowsAtOnceBeforeTheIPhoneAnswers() {
        var state = WatchState(snapshot: snapshot([reading, water]))

        state.add(mark(water))
        state.add(mark(water))

        #expect(state.shown?.habits[1].count(on: today) == 2)
        #expect(state.snapshot?.habits[1].count(on: today) == 0)
    }

    @Test func aGridSentBeforeTheTapArrivedNeverTakesItBack() {
        var state = WatchState(snapshot: snapshot([reading]))
        state.add(mark(reading))

        state.receive(snapshot([reading]))

        #expect(state.pending.count == 1)
        #expect(state.shown?.habits[0].isDone(on: today) == true)
    }

    @Test func aTapTheIPhoneAppliedIsNoLongerPending() {
        var state = WatchState(snapshot: snapshot([water]))
        let first = mark(water)
        let second = mark(water)
        state.add(first)
        state.add(second)
        var saved = water
        saved.mark(on: today, hour: 9)

        state.receive(snapshot([saved], applied: [first.id]))

        #expect(state.pending == [second])
        // The applied tap counts once, from the iPhone's grid.
        #expect(state.shown?.habits[0].count(on: today) == 2)
    }

    @Test func aNewDayDropsTheTapsOfTheDayBefore() {
        var state = WatchState(snapshot: snapshot([reading]))
        state.add(mark(reading))

        state.receive(snapshot([reading], on: today + 1))

        #expect(state.pending.isEmpty)
        #expect(state.shown?.habits[0].isDone(on: today + 1) == false)
    }

    @Test func theStateSurvivesTheWatchRestarting() throws {
        let store = WatchStateStore(url: .temporaryDirectory.appending(path: "WatchStateTests-\(UUID().uuidString).json"))
        var state = WatchState(snapshot: snapshot([reading, water]))
        state.add(mark(water))

        try store.save(state)

        #expect(store.load() == state)
    }

    @Test func anUnreadableFileStartsEmpty() throws {
        let url = URL.temporaryDirectory.appending(path: "WatchStateTests-\(UUID().uuidString).json")
        try Data("non è JSON".utf8).write(to: url)

        #expect(WatchStateStore(url: url).load() == WatchState())
    }
}
