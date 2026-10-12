import Foundation
import Testing
@testable import SbuHabits

/// Bugs found in review: each test fails on the code before its fix.
struct ReviewFixTests {
    private let today = LogicalDay(ordinal: 1_004) // a Sunday; weeks start on Monday here
    private let monday = 2

    @Test func raisingTimesPerDayKeepsThePastSerie() {
        var habit = Habit(title: "Bere acqua", symbol: "drop", createdOn: today - 40)
        for daysAgo in 1...40 {
            habit.log[today - daysAgo] = 1
        }

        _ = habit.update(title: "Bere acqua", symbol: "drop", timesPerDay: 2, schedule: .everyDay, from: today)

        #expect(Streak.current(of: habit, today: today, firstWeekday: monday) == 40)
        #expect(Streak.best(of: habit, today: today, firstWeekday: monday) == 40)
        #expect(DayState(of: habit, on: today - 3, today: today) == .done)
        #expect(habit.isDone(on: today) == false)
        habit.log[today] = 1
        #expect(habit.isDone(on: today) == false) // today asks for two
    }

    @Test func widerScheduleDoesNotTurnPastRestDaysIntoMisses() {
        var mondays = Habit(title: "Piante", symbol: "leaf", schedule: .weekdays([2]), createdOn: today - 30)
        mondays.log[today - 6] = 1
        mondays.log[today - 13] = 1

        _ = mondays.update(title: "Piante", symbol: "leaf", timesPerDay: 1, schedule: .everyDay, from: today)

        #expect(Streak.current(of: mondays, today: today, firstWeekday: monday) == 2)
        #expect(DayState(of: mondays, on: today - 2, today: today) == .empty)
    }

    @Test func editingTwiceTheSameDayKeepsTheFirstPastRules() {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 10)

        _ = habit.update(title: "Leggere", symbol: "book", timesPerDay: 3, schedule: .everyDay, from: today)
        _ = habit.update(title: "Leggere", symbol: "book", timesPerDay: 5, schedule: .everyDay, from: today)

        #expect(habit.timesPerDay(on: today - 1) == 1)
        #expect(habit.timesPerDay(on: today) == 5)
    }

    @Test func aWeekWithEveryDaySkippedIsNeutral() {
        var gym = Habit(title: "Palestra", symbol: "dumbbell", schedule: .timesPerWeek(3), createdOn: today - 30)
        // Two weeks ago reached; last week every day skipped; the week before that reached too.
        for daysAgo in [14, 15, 16, 21, 22, 23] {
            gym.log[today - daysAgo] = 1
        }
        gym.skipped = Set((7...13).map { today - $0 })

        #expect(Streak.current(of: gym, today: today, firstWeekday: monday) == 2)
        #expect(Streak.best(of: gym, today: today, firstWeekday: monday) == 2)
    }

    @Test func anUnreadableFileIsNeverOverwritten() throws {
        let store = HabitsStore(url: .temporaryDirectory.appending(path: "ReviewFixTests-\(UUID().uuidString).json"))
        let garbage = Data(#"{"version": 1, "habits": "not a list"}"#.utf8)
        try garbage.write(to: store.url)
        let model = HabitsModel(store: store, scheduleReminders: { _ in })

        model.add(title: "Leggere", symbol: "book")

        #expect(model.isUnreadable)
        #expect(try Data(contentsOf: store.url) == garbage)
    }

    @Test func aMarkAfterMidnightGoesOnTheNewDay() throws {
        var rome = Calendar(identifier: .gregorian)
        rome.timeZone = try #require(TimeZone(identifier: "Europe/Rome"))
        let evening = try #require(rome.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23, minute: 55)))
        let clock = Clock(now: evening)
        let store = HabitsStore(url: .temporaryDirectory.appending(path: "ReviewFixTests-\(UUID().uuidString).json"))
        let model = HabitsModel(store: store, now: { clock.now }, calendar: rome, scheduleReminders: { _ in })
        model.add(title: "Leggere", symbol: "book")

        clock.now = evening.addingTimeInterval(10 * 60) // 00:05, the app still open
        model.markDone(model.habits[0])

        #expect(model.today == LogicalDay(clock.now, calendar: rome))
        #expect(model.habits[0].isDone(on: model.today))
    }

    /// A settable clock for the model.
    private final class Clock {
        var now: Date

        init(now: Date) {
            self.now = now
        }
    }
}
