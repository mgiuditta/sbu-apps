import Foundation
import Testing
@testable import SbuHabits

struct ReminderPlanTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        calendar.firstWeekday = 2
        return calendar
    }()

    /// Monday 12 October 2026 at `hour`.
    private func monday(at hour: Int, minute: Int = 0, plusDays days: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 12 + days, hour: hour, minute: minute))!
    }

    private var today: LogicalDay { LogicalDay(monday(at: 12), calendar: calendar) }

    private func habit(_ schedule: Schedule = .everyDay, at times: [ReminderTime] = [ReminderTime(hour: 20, minute: 0)]) -> Habit {
        var habit = Habit(title: "Leggere", symbol: "book", schedule: schedule, createdOn: today - 30)
        habit.reminders = times
        return habit
    }

    private func plan(_ habits: [Habit], now: Date? = nil, startHour: Int = 0) -> [PlannedReminder] {
        ReminderPlan.reminders(for: habits, now: now ?? monday(at: 12), startHour: startHour, calendar: calendar)
    }

    @Test func aDailyHabitIsRemindedEveryDayAhead() {
        let dates = plan([habit()]).map(\.date)

        #expect(dates == (0..<ReminderPlan.days).map { monday(at: 20, plusDays: $0) })
    }

    @Test func onlyExpectedDaysAreReminded() {
        let dates = plan([habit(.weekdays([2, 4]))]).map(\.date).prefix(4) // Mondays and Wednesdays

        #expect(Array(dates) == [monday(at: 20), monday(at: 20, plusDays: 2), monday(at: 20, plusDays: 7), monday(at: 20, plusDays: 9)])
    }

    @Test func aHabitDoneOrSkippedTodayIsNotRemindedToday() {
        var done = habit()
        done.mark(on: today, hour: 9)
        var skipped = habit()
        skipped.toggleSkip(on: today)

        #expect(plan([done]).first?.date == monday(at: 20, plusDays: 1))
        #expect(plan([skipped]).first?.date == monday(at: 20, plusDays: 1))
    }

    @Test func aTimeAlreadyPastTodayWaitsForTomorrow() {
        #expect(plan([habit()], now: monday(at: 21)).first?.date == monday(at: 20, plusDays: 1))
    }

    @Test func aWeeklyHabitIsRemindedUntilItsGoalIsReached() {
        var gym = habit(.timesPerWeek(1))
        #expect(plan([gym]).first?.date == monday(at: 20))

        gym.log[today] = 1 // done today, Monday: this week's goal is reached

        // Nothing more this week; reminders start again next Monday.
        #expect(plan([gym]).first?.date == monday(at: 20, plusDays: 7))
    }

    @Test func anHourBeforeTheStartOfTheDayFallsTheNextMorning() {
        let night = habit(at: [ReminderTime(hour: 2, minute: 30)])

        #expect(plan([night], startHour: 4).first?.date == monday(at: 2, minute: 30, plusDays: 1))
    }

    @Test func thePlanIsSortedAndStaysWithinTheLimit() {
        let habits = (0..<20).map { _ in habit(at: [ReminderTime(hour: 21, minute: 0), ReminderTime(hour: 13, minute: 0), ReminderTime(hour: 18, minute: 30)]) }

        let dates = plan(habits).map(\.date)

        #expect(dates.count == ReminderPlan.limit)
        #expect(dates == dates.sorted())
        #expect(Set(plan(habits).map(\.id)).count == ReminderPlan.limit)
    }

    @Test func markingAHabitDoneReplansWithoutTodaysReminder() {
        var latest: [PlannedReminder] = []
        let store = HabitsStore(url: .temporaryDirectory.appending(path: "ReminderPlanTests-\(UUID().uuidString).json"))
        let model = HabitsModel(store: store, now: { [calendar] in calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 12))! }, calendar: calendar) { latest = $0 }
        model.add(title: "Leggere", symbol: "book", reminders: [ReminderTime(hour: 20, minute: 0)])
        #expect(latest.first?.date == monday(at: 20))

        model.markDone(model.habits[0])

        #expect(latest.first?.date == monday(at: 20, plusDays: 1))
    }
}
