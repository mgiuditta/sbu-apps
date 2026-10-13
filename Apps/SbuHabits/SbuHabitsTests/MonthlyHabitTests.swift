import Foundation
import Testing
@testable import SbuHabits

/// N volte al mese: counted per calendar month, in months. Days are built in UTC, where a logical
/// day starting at midnight is the calendar day.
struct MonthlyHabitTests {
    private nonisolated static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        calendar.firstWeekday = 2
        return calendar
    }()

    private nonisolated static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        utc.date(from: DateComponents(year: year, month: month, day: day, hour: hour)) ?? .distantPast
    }

    private nonisolated static func day(_ year: Int, _ month: Int, _ day: Int) -> LogicalDay {
        LogicalDay(date(year, month, day), calendar: utc)
    }

    /// A habit `times` a month, started on 1 January 2026, done on `doneOn`.
    private func library(times: Int = 2, createdOn: LogicalDay = day(2026, 1, 1), doneOn: [LogicalDay]) -> Habit {
        var habit = Habit(title: "Biblioteca", symbol: "books.vertical", schedule: .timesPerMonth(times), createdOn: createdOn)
        for day in doneOn {
            habit.log[day] = 1
        }
        return habit
    }

    // MARK: - Months

    @Test(arguments: [
        (day(2026, 1, 31), day(2026, 1, 1), 31),
        (day(2026, 2, 14), day(2026, 2, 1), 28),
        (day(2024, 2, 29), day(2024, 2, 1), 29), // leap year
        (day(2000, 2, 10), day(2000, 2, 1), 29), // divisible by 400: leap
        (day(2100, 2, 10), day(2100, 2, 1), 28), // divisible by 100: not leap
        (day(2026, 4, 1), day(2026, 4, 1), 30),
        (day(2026, 12, 31), day(2026, 12, 1), 31),
    ])
    func aMonthRunsFromThe1stToItsLastDay(day: LogicalDay, start: LogicalDay, length: Int) {
        #expect(day.monthStart == start)
        #expect(day.daysInMonth == length)
        #expect(SchedulePeriod.month.end(of: day, firstWeekday: 2) == start + length - 1)
    }

    @Test(arguments: 1...7)
    func theFirstWeekdayNeverMovesAMonth(firstWeekday: Int) {
        let day = Self.day(2026, 3, 18)

        #expect(SchedulePeriod.month.start(of: day, firstWeekday: firstWeekday) == Self.day(2026, 3, 1))
        #expect(SchedulePeriod.month.end(of: day, firstWeekday: firstWeekday) == Self.day(2026, 3, 31))
    }

    @Test(arguments: [0, 4])
    func anHourBeforeTheStartOfTheDayStaysInTheMonthBefore(startHour: Int) {
        let night = Self.date(2026, 3, 1, hour: 2)

        let month = LogicalDay(night, startHour: startHour, calendar: Self.utc).monthStart

        #expect(month == (startHour == 0 ? Self.day(2026, 3, 1) : Self.day(2026, 2, 1)))
    }

    // MARK: - Schedule

    @Test(arguments: [Self.day(2026, 3, 1), Self.day(2026, 3, 15), Self.day(2026, 3, 31)])
    func aMonthlyHabitHasNoFixedDays(day: LogicalDay) {
        #expect(Schedule.timesPerMonth(5).includes(day) == false)
        #expect(Schedule.timesPerMonth(5).period == .month)
        #expect(Schedule.timesPerMonth(5).timesPerPeriod == 5)
    }

    // MARK: - Progress

    @Test(arguments: [
        ([day(2026, 3, 1), day(2026, 3, 5)], 2),
        ([day(2026, 2, 28), day(2026, 3, 10)], 1), // February is another month
        ([day(2026, 3, 11)], 0), // tomorrow
    ])
    func progressCountsTheDaysDoneThisMonth(doneOn: [LogicalDay], done: Int) {
        let progress = HabitProgress(of: library(times: 3, doneOn: doneOn), today: Self.day(2026, 3, 10), firstWeekday: 2)

        #expect(progress.done == done)
        #expect(progress.goal == 3)
    }

    @Test func eachSkippedDayLowersTheMonthsGoal() {
        var habit = library(times: 3, doneOn: [])
        habit.toggleSkip(on: Self.day(2026, 3, 2))

        #expect(HabitProgress(of: habit, today: Self.day(2026, 3, 10), firstWeekday: 2).goal == 2)
    }

    // MARK: - Serie

    /// Today is 15 May 2026; the habit asks for two days a month since January.
    @Test(arguments: [
        ([day(2026, 1, 3), day(2026, 1, 4), day(2026, 2, 10), day(2026, 2, 28), day(2026, 3, 1), day(2026, 3, 31), day(2026, 4, 1), day(2026, 4, 30)], 4), // May not reached yet: it does not break
        ([day(2026, 1, 3), day(2026, 1, 4), day(2026, 2, 10), day(2026, 2, 28), day(2026, 3, 1), day(2026, 3, 31), day(2026, 4, 1), day(2026, 4, 30), day(2026, 5, 2), day(2026, 5, 3)], 5), // May reached too
        ([day(2026, 1, 3), day(2026, 1, 4), day(2026, 2, 28), day(2026, 3, 1), day(2026, 3, 31), day(2026, 4, 1), day(2026, 4, 30)], 2), // February fell short
        ([day(2026, 1, 31), day(2026, 2, 1), day(2026, 2, 28), day(2026, 3, 1), day(2026, 3, 31), day(2026, 4, 1), day(2026, 4, 30)], 3), // last and first days: January had one
        ([LogicalDay](), 0),
    ])
    func theSerieCountsMonthsInARowWithTheGoalReached(doneOn: [LogicalDay], months: Int) {
        #expect(Streak.current(of: library(doneOn: doneOn), today: Self.day(2026, 5, 15), firstWeekday: 2) == months)
    }

    @Test(arguments: [
        (2024, [day(2024, 1, 15), day(2024, 2, 29)], 2), // 29 February counts for February
        (2025, [day(2025, 1, 15), day(2025, 2, 28)], 2),
        (2025, [day(2025, 1, 15), day(2025, 3, 1)], 1), // February missed: March alone
    ])
    func februaryEndsOnItsLastDayInLeapYearsAndOthers(year: Int, doneOn: [LogicalDay], months: Int) {
        let habit = library(times: 1, createdOn: Self.day(year, 1, 1), doneOn: doneOn)

        #expect(Streak.current(of: habit, today: Self.day(year, 3, 10), firstWeekday: 2) == months)
    }

    @Test func theBestSerieCountsMonthsToo() {
        let doneOn = [Self.day(2026, 1, 3), Self.day(2026, 1, 4), Self.day(2026, 2, 1), Self.day(2026, 2, 2), Self.day(2026, 3, 5), Self.day(2026, 4, 1), Self.day(2026, 4, 2)]

        #expect(Streak.best(of: library(doneOn: doneOn), today: Self.day(2026, 5, 15), firstWeekday: 2) == 2)
    }

    @Test func monthlyHabitsStayOutOfTheFullStreak() {
        let today = Self.day(2026, 3, 10)
        var daily = Habit(title: "Leggere", symbol: "book", createdOn: today - 30)
        for daysAgo in 0...3 {
            daily.log[today - daysAgo] = 1
        }

        #expect(Streak.full(of: [daily, library(doneOn: [])], today: today) == 4)
        #expect(Streak.full(of: [library(doneOn: [today])], today: today) == 0)
    }

    // MARK: - Grid, reminders, history

    @Test(arguments: [
        ([LogicalDay](), true), // goal not reached
        ([day(2026, 3, 1), day(2026, 3, 2)], false), // reached, not marked today
        ([day(2026, 3, 1), day(2026, 3, 10)], true), // reached today: stays to show it
    ])
    func theGridShowsAMonthlyHabitUntilItsGoal(doneOn: [LogicalDay], isShown: Bool) {
        let shown = TodayGrid.habits([library(doneOn: doneOn)], on: Self.day(2026, 3, 10), firstWeekday: 2)

        #expect(shown.isEmpty != isShown)
    }

    @Test func aMonthlyHabitIsRemindedUntilItsGoalThenFromTheNextMonth() {
        var habit = library(times: 1, doneOn: [Self.day(2026, 3, 30)])
        habit.reminders = [ReminderTime(hour: 20, minute: 0)]

        let plan = ReminderPlan.reminders(for: [habit], now: Self.date(2026, 3, 30), startHour: 0, calendar: Self.utc)

        // March's goal is reached today: the next reminder is on 1 April.
        #expect(plan.first?.date == Self.date(2026, 4, 1, hour: 20))
    }

    @Test(arguments: [Self.day(2026, 3, 9), Self.day(2026, 3, 1)])
    func aDayNotDoneIsNeverAMiss(day: LogicalDay) {
        #expect(DayState(of: library(doneOn: []), on: day, today: Self.day(2026, 3, 10)) == .empty)
    }

    // MARK: - Form rules

    @Test(arguments: [(40, 27), (0, 1), (12, 12)])
    func aMonthlyHabitIsDoneOnceADayWithinTheRange(times: Int, kept: Int) {
        let model = HabitsModel(store: HabitsStore(url: .temporaryDirectory.appending(path: "MonthlyHabitTests-\(UUID().uuidString).json")), scheduleReminders: { _ in })

        model.add(title: "Biblioteca", symbol: "books.vertical", timesPerDay: 4, schedule: .timesPerMonth(times))

        #expect(model.habits[0].timesPerDay == 1)
        #expect(model.habits[0].schedule == .timesPerMonth(kept))
    }

    @Test func anAbitudineDaEvitareIsNeverMonthly() {
        let model = HabitsModel(store: HabitsStore(url: .temporaryDirectory.appending(path: "MonthlyHabitTests-\(UUID().uuidString).json")), scheduleReminders: { _ in })

        model.add(title: "Caffè", symbol: "cup.and.saucer", schedule: .timesPerMonth(3), limit: 2)

        #expect(model.habits[0].schedule == .everyDay)
    }

    @Test func aMarkBeforeTheStartOfTheDayCountsForTheMonthBefore() throws {
        let clock = TestClock(Self.date(2026, 3, 1, hour: 2))
        let model = HabitsModel(
            store: HabitsStore(url: .temporaryDirectory.appending(path: "MonthlyHabitTests-\(UUID().uuidString).json")),
            now: { clock.now },
            calendar: Self.utc,
            scheduleReminders: { _ in }
        )
        model.setStartHour(4)
        model.add(title: "Biblioteca", symbol: "books.vertical", schedule: .timesPerMonth(1))
        let habit = try #require(model.habits.first)

        model.markDone(habit)

        #expect(model.today == Self.day(2026, 2, 28))
        #expect(model.progress(of: model.habits[0]).isComplete)
        clock.advance(by: 3 * 3600) // 05:00, 1 March: a new day and a new month
        model.reload()
        #expect(model.progress(of: model.habits[0]).done == 0)
        #expect(model.streak(of: model.habits[0]) == 1)
    }

    @Test func theStatisticsSayMonths() {
        #expect(Schedule.timesPerMonth(2).streakText(3).key == "%lld mesi")
        #expect(Schedule.timesPerWeek(2).streakText(3).key == "%lld settimane")
        #expect(Schedule.oneDay(Self.day(2026, 3, 1)).streakText(3).key == "%lld giorni")
    }
}
