import Foundation
import Testing
@testable import SbuHabits

struct StreakTests {
    private let today = LogicalDay(ordinal: 1_000)

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
        #expect(Streak.current(of: habit(doneDaysAgo: doneDaysAgo), today: today) == expected)
    }

    @Test(arguments: [(3, true), (2, false), (0, false)])
    func aDayCountsOnlyWhenEveryTimeIsDone(timesYesterday: Int, counts: Bool) {
        var habit = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 3, createdOn: today - 30)
        habit.log[today - 1] = timesYesterday
        habit.log[today - 2] = 3

        #expect(Streak.current(of: habit, today: today) == (counts ? 2 : 0))
        #expect(Streak.full(of: [habit], today: today) == (counts ? 2 : 0))
    }

    @Test func nothingBeforeCreationCounts() {
        // Marks before the creation day, like a bad clock, never enter the streak.
        let habit = habit(age: 1, doneDaysAgo: [0, 1, 2, 3])

        #expect(Streak.current(of: habit, today: today) == 2)
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
}
