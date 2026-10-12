import Foundation
import Testing
@testable import SbuHabits

struct StreakTests {
    private let today = LogicalDay(ordinal: 1_004) // a Sunday

    /// A habit created `age` days ago and done on the given days ago (0 is today).
    private func habit(age: Int = 30, doneDaysAgo: [Int]) -> Habit {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - age)
        for daysAgo in doneDaysAgo {
            habit.log[today - daysAgo] = 1
        }
        return habit
    }

    @Test(arguments: [
        ([0, 1, 2], 3), // done today and the two days before
        ([1, 2], 2), // today not done yet does not break it
        ([0, 2, 3], 1), // yesterday missed
        ([1, 3], 1), // missed the day before yesterday
        ([], 0),
    ])
    func countsDaysInARowUpToToday(doneDaysAgo: [Int], expected: Int) {
        #expect(Streak.current(of: habit(doneDaysAgo: doneDaysAgo), today: today, firstWeekday: 2) == expected)
    }

    @Test(arguments: [(3, true), (2, false), (0, false)])
    func aDayCountsOnlyWhenEveryTimeIsDone(timesYesterday: Int, counts: Bool) {
        var habit = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 3, createdOn: today - 30)
        habit.log[today - 1] = timesYesterday
        habit.log[today - 2] = 3

        #expect(Streak.current(of: habit, today: today, firstWeekday: 2) == (counts ? 2 : 0))
        #expect(Streak.full(of: [habit], today: today) == (counts ? 2 : 0))
    }

    @Test func nothingBeforeCreationCounts() {
        // Marks before the creation day, like a bad clock, never enter the streak.
        let habit = habit(age: 1, doneDaysAgo: [0, 1, 2, 3])

        #expect(Streak.current(of: habit, today: today, firstWeekday: 2) == 2)
    }

    @Test(arguments: [
        ([[0, 1, 2], [0, 1, 2]], 3), // all done
        ([[1, 2], [1, 2]], 2), // today not complete yet
        ([[0, 1, 2], [1, 2]], 2), // one done today, the other not yet
        ([[0, 1, 2], [0, 2]], 1), // one missed yesterday
        ([[Int](), []], 0),
    ])
    func fullStreakNeedsEveryHabit(doneDaysAgo: [[Int]], expected: Int) {
        let habits = doneDaysAgo.map { habit(doneDaysAgo: $0) }

        #expect(Streak.full(of: habits, today: today) == expected)
    }

    @Test func aNewHabitDoesNotBreakTheFullStreakOfDaysBeforeIt() {
        let old = habit(age: 10, doneDaysAgo: [0, 1, 2, 3])
        let new = habit(age: 1, doneDaysAgo: [0, 1])

        #expect(Streak.full(of: [old, new], today: today) == 4)
    }

    @Test func noHabitsMeansNoFullStreak() {
        #expect(Streak.full(of: [], today: today) == 0)
    }

    // today is a Sunday, weekday 1; weekday 2 is Monday.

    @Test func daysNotExpectedNeitherBreakNorCount() {
        // Every Monday, Wednesday and Friday, done on the last three of them.
        var habit = Habit(title: "Palestra", symbol: "dumbbell", schedule: .weekdays([2, 4, 6]), createdOn: today - 30)
        for daysAgo in [2, 4, 6] { // Friday, Wednesday, Monday
            habit.log[today - daysAgo] = 1
        }

        #expect(Streak.current(of: habit, today: today, firstWeekday: 2) == 3)
    }

    @Test func aMissedExpectedDayBreaksTheSerie() {
        var habit = Habit(title: "Palestra", symbol: "dumbbell", schedule: .weekdays([2, 4, 6]), createdOn: today - 30)
        habit.log[today - 2] = 1 // Friday done, Wednesday missed

        #expect(Streak.current(of: habit, today: today, firstWeekday: 2) == 1)
    }

    @Test func fullStreakConsidersOnlyHabitsExpectedThatDay() {
        let daily = habit(doneDaysAgo: Array(0...6))
        let weekend = Habit(title: "Gita", symbol: "leaf", schedule: .weekdays([1, 7]), createdOn: today - 30)

        // The weekend habit is expected today and yesterday and was never done: today does not
        // break, yesterday (Saturday) does.
        #expect(Streak.full(of: [daily, weekend], today: today) == 0)
        #expect(Streak.full(of: [daily, weekend], today: today - 2) == 5)
    }

    @Test func aDayWithNothingExpectedIsNeutral() {
        var mondays = Habit(title: "Piante", symbol: "leaf", schedule: .weekdays([2]), createdOn: today - 30)
        mondays.log[today - 6] = 1
        mondays.log[today - 13] = 1

        #expect(Streak.full(of: [mondays], today: today) == 2)
    }

    @Test func theGridShowsOnlyHabitsExpectedToday() {
        let daily = habit(doneDaysAgo: [])
        let sundays = Habit(title: "Chiamare casa", symbol: "phone", schedule: .weekdays([1]), createdOn: today)
        let mondays = Habit(title: "Piante", symbol: "leaf", schedule: .weekdays([2]), createdOn: today)

        #expect(TodayGrid.habits([daily, sundays, mondays], on: today, firstWeekday: 2).map(\.title) == ["Leggere", "Chiamare casa"])
    }
}
