import Foundation
import Testing
@testable import SbuHabits

/// The calendar widget: this month's days, done, missed, skipped, today and the rest.
struct MonthCalendarTests {
    /// Tuesday 13 October 2026.
    private let today = LogicalDay(ordinal: 20_739)
    /// Thursday 1 October 2026.
    private let firstOfMonth = LogicalDay(ordinal: 20_727)

    /// Every day from 4 October: done on the 5th, missed on the 6th, skipped on the 7th.
    private var reading: Habit {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: firstOfMonth + 3)
        habit.log[firstOfMonth + 4] = 1
        habit.skipped = [firstOfMonth + 6]
        return habit
    }

    @Test(arguments: [
        (20_739, 31, 20_727), // October 2026
        (20_512, 28, 20_485), // February 2026
        (20_485, 28, 20_485), // its first day
    ])
    func theMonthStartsOnTheFirst(todayOrdinal: Int, days: Int, firstOrdinal: Int) {
        let dots = MonthCalendar.dots(of: reading, today: LogicalDay(ordinal: todayOrdinal))

        #expect(dots.count == days)
        #expect(dots.first?.day == LogicalDay(ordinal: firstOrdinal))
        #expect(zip(dots, dots.dropFirst()).allSatisfy { $1.day == $0.day + 1 })
    }

    @Test(arguments: [
        (0, CalendarDotState.rest), // before the habit began
        (4, .done),
        (5, .missed),
        (6, .skipped),
        (12, .today),
        (13, .rest), // still to come
        (30, .rest),
    ])
    func eachDayHasItsState(offset: Int, state: CalendarDotState) throws {
        let dots = MonthCalendar.dots(of: reading, today: today)

        let dot = try #require(dots.first { $0.day == firstOfMonth + offset })
        #expect(dot.state == state)
    }

    @Test func todayDoneIsAFullDot() {
        var habit = reading
        habit.log[today] = 1

        #expect(MonthCalendar.dots(of: habit, today: today).first { $0.day == today }?.state == .done)
    }

    @Test(arguments: [(1, CalendarDotState.today), (3, .missed)])
    func anAvoidedHabitMissesTodayOnlyOverTheLimite(times: Int, state: CalendarDotState) {
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: firstOfMonth)
        coffee.log[today] = times

        #expect(MonthCalendar.dots(of: coffee, today: today).first { $0.day == today }?.state == state)
    }

    @Test func aDayNotExpectedIsNeverAMissButTodayStillShows() {
        // Only on Mondays: 12 October is one, 11 and 13 October are not.
        let plants = Habit(title: "Piante", symbol: "leaf", schedule: .weekdays([2]), createdOn: firstOfMonth)

        let dots = MonthCalendar.dots(of: plants, today: today)

        #expect(dots.first { $0.day == today - 1 }?.state == .missed)
        #expect(dots.first { $0.day == today - 2 }?.state == .rest)
        // The ring says where today is, expected or not.
        #expect(dots.first { $0.day == today }?.state == .today)
    }

    @Test func aWeeklyHabitHasNoMisses() {
        var weekly = Habit(title: "Correre", symbol: "figure.run", schedule: .timesPerWeek(3), createdOn: firstOfMonth)
        weekly.log[today - 1] = 1

        let states = Set(MonthCalendar.dots(of: weekly, today: today).map(\.state))

        #expect(states == [.done, .today, .rest])
    }
}
