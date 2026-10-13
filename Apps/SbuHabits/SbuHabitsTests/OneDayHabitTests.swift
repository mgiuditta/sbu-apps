import Foundation
import Testing
@testable import SbuHabits

/// Attività di un giorno: expected on its one day, neutral on every other.
struct OneDayHabitTests {
    private let today = LogicalDay(ordinal: 20_010)

    private func dentist(on day: LogicalDay, createdOn: LogicalDay? = nil) -> Habit {
        Habit(title: "Dentista", symbol: "pills", schedule: .oneDay(day), createdOn: createdOn ?? today - 5)
    }

    /// A daily habit done every day of the last `days`, today included.
    private func reading(doneFor days: Int) -> Habit {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 30)
        for daysAgo in 0..<days {
            habit.log[today - daysAgo] = 1
        }
        return habit
    }

    @Test(arguments: [(-1, false), (0, true), (1, false), (365, false)])
    func itIsExpectedOnItsDayOnly(offset: Int, isExpected: Bool) {
        #expect(Schedule.oneDay(today).includes(today + offset) == isExpected)
        #expect(Schedule.oneDay(today).period == nil)
    }

    @Test(arguments: [(-1, false), (0, true), (3, false)])
    func theGridShowsItOnItsDayOnly(daysFromItsDay: Int, isShown: Bool) {
        let shown = TodayGrid.habits([dentist(on: today - daysFromItsDay)], on: today, firstWeekday: 2)

        #expect(shown.isEmpty != isShown)
    }

    @Test(arguments: [
        (2, true, 10), // its day, two days ago, done: the Serie piena goes through
        (2, false, 2), // its day missed: the Serie piena stops there
        (-3, false, 10), // still to come: nothing asked yet
    ])
    func onlyItsDayCountsForTheFullStreak(daysAgo: Int, isDone: Bool, fullStreak: Int) {
        var task = dentist(on: today - daysAgo, createdOn: today - 10)
        if isDone {
            task.log[today - daysAgo] = 1
        }

        #expect(Streak.full(of: [reading(doneFor: 10), task], today: today) == fullStreak)
    }

    @Test func todayNotDoneYetBreaksNothing() {
        let task = dentist(on: today)

        #expect(Streak.full(of: [reading(doneFor: 10), task], today: today) == 9)
        #expect(Streak.current(of: task, today: today, firstWeekday: 2) == 0)
    }

    @Test func skippingItsDayKeepsTheFullStreak() {
        var task = dentist(on: today - 2, createdOn: today - 10)
        task.toggleSkip(on: today - 2)

        #expect(Streak.full(of: [reading(doneFor: 10), task], today: today) == 10)
    }

    @Test(arguments: [(true, 1), (false, 0)])
    func itsSerieIsItsOneDay(isDone: Bool, streak: Int) {
        var task = dentist(on: today - 2)
        if isDone {
            task.log[today - 2] = 1
        }

        #expect(Streak.current(of: task, today: today, firstWeekday: 2) == streak)
        #expect(Streak.best(of: task, today: today, firstWeekday: 2) == streak)
    }

    @Test(arguments: [(-1, DayState.empty), (0, .missed), (1, .empty)])
    func itsHistoryMissesOnlyItsDay(offset: Int, state: DayState) {
        let task = dentist(on: today - 2)

        #expect(DayState(of: task, on: today - 2 + offset, today: today) == state)
    }

    @Test func itIsRemindedOnItsDayOnly() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        var task = dentist(on: today + 3)
        task.reminders = [ReminderTime(hour: 8, minute: 0)]
        let now = today.noon(in: calendar)

        let plan = ReminderPlan.reminders(for: [task], now: now, startHour: 0, calendar: calendar)

        let only = try #require(plan.first)
        #expect(plan.count == 1)
        #expect(LogicalDay(only.date, calendar: calendar) == today + 3)
    }

    @Test func anAbitudineDaEvitareIsNeverAnAttivitaDiUnGiorno() {
        var habit = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today)

        _ = habit.update(title: "Caffè", symbol: "cup.and.saucer", timesPerDay: 1, schedule: .oneDay(today), limit: 2, from: today)

        #expect(habit.schedule == .everyDay)
    }

    @Test func itKeepsItsTimesPerDay() {
        var habit = Habit(title: "Dentista", symbol: "pills", createdOn: today)

        _ = habit.update(title: "Dentista", symbol: "pills", timesPerDay: 3, schedule: .oneDay(today + 1), from: today)

        #expect(habit.schedule == .oneDay(today + 1))
        #expect(habit.timesPerDay == 3)
    }
}
