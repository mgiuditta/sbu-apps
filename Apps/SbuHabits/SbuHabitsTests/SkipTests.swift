import Foundation
import Testing
@testable import SbuHabits

/// Salta oggi: a skipped day is neutral, and a weekly habit's goal drops by one.
struct SkipTests {
    private let today = LogicalDay(ordinal: 1_004) // a Sunday; weeks start on Monday here
    private let monday = 2

    private func habit(_ schedule: Schedule = .everyDay, done: [Int], skipped: [Int]) -> Habit {
        var habit = Habit(title: "Leggere", symbol: "book", schedule: schedule, createdOn: today - 60)
        for daysAgo in done {
            habit.log[today - daysAgo] = 1
        }
        habit.skipped = Set(skipped.map { today - $0 })
        return habit
    }

    @Test(arguments: [
        ([0, 2, 3], [1], 3), // yesterday skipped: neither breaks nor counts
        ([0, 1, 2], [], 3),
        ([0, 2], [], 1), // yesterday missed
        ([2, 3], [0, 1], 2), // today and yesterday skipped
    ])
    func aSkippedDayIsNeutralForTheSerie(done: [Int], skipped: [Int], expected: Int) {
        #expect(Streak.current(of: habit(done: done, skipped: skipped), today: today, firstWeekday: monday) == expected)
    }

    @Test func aSkippedHabitDropsOutOfThatDayOfTheFullStreak() {
        let reading = habit(done: [0, 1, 2], skipped: [])
        let walking = habit(done: [0, 2], skipped: [1])

        #expect(Streak.full(of: [reading, walking], today: today) == 3)
    }

    @Test func aDayWithEverythingSkippedIsNeutral() {
        let reading = habit(done: [0, 2], skipped: [1])
        let walking = habit(done: [0, 2], skipped: [1])

        #expect(Streak.full(of: [reading, walking], today: today) == 2)
    }

    @Test(arguments: [
        ([Int](), 3),
        ([0], 2),
        ([0, 1], 1),
    ])
    func eachSkippedDayLowersTheWeeksGoal(skipped: [Int], goal: Int) {
        let gym = habit(.timesPerWeek(3), done: [], skipped: skipped)

        #expect(HabitProgress(of: gym, today: today, firstWeekday: monday).goal == goal)
    }

    @Test func aWeekReachedThanksToASkipCountsInTheSerie() {
        // Last week: two days done and one skipped, with a goal of three.
        let gym = habit(.timesPerWeek(3), done: [7, 9], skipped: [11])

        #expect(Streak.current(of: gym, today: today, firstWeekday: monday) == 1)
    }

    @Test func skippingClearsTodaysMarksAndCanBeTakenBack() {
        var habit = habit(done: [0], skipped: [])

        habit.toggleSkip(on: today)
        #expect(habit.isSkipped(on: today))
        #expect(habit.count(on: today) == 0)

        habit.toggleSkip(on: today)
        #expect(habit.isSkipped(on: today) == false)
    }

    @Test func markingASkippedDayTakesTheSkipBack() {
        var habit = habit(done: [], skipped: [0])

        habit.mark(on: today, hour: 9)

        #expect(habit.isSkipped(on: today) == false)
        #expect(habit.isDone(on: today))
    }
}
