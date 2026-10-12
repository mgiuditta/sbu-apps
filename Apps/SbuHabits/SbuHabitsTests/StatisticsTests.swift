import Foundation
import Testing
@testable import SbuHabits

struct StatisticsTests {
    private let today = LogicalDay(ordinal: 1_004) // a Sunday; weeks start on Monday here
    private let monday = 2

    private func habit(_ schedule: Schedule = .everyDay, age: Int = 30, done: [Int], skipped: [Int] = []) -> Habit {
        var habit = Habit(title: "Leggere", symbol: "book", schedule: schedule, createdOn: today - age)
        for daysAgo in done {
            habit.log[today - daysAgo] = 1
        }
        habit.skipped = Set(skipped.map { today - $0 })
        return habit
    }

    @Test(arguments: [
        ([1, 2, 10, 11, 12, 13], 4), // the best run was a week ago
        ([0, 1, 2, 5], 3), // the current one is the best
        ([1, 3, 4], 2), // today not done does not reset it
        ([Int](), 0),
    ])
    func theBestSerieIsTheLongestRun(done: [Int], best: Int) {
        #expect(Streak.best(of: habit(done: done), today: today, firstWeekday: monday) == best)
    }

    @Test func skippedDaysDoNotBreakTheBestSerie() {
        #expect(Streak.best(of: habit(done: [1, 3, 4], skipped: [2]), today: today, firstWeekday: monday) == 3)
    }

    @Test func theBestWeeklySerieCountsWeeks() {
        // Three weeks reached in a row, two to four weeks ago; last week fell short.
        let gym = habit(.timesPerWeek(2), age: 60, done: [7, 14, 15, 21, 22, 28, 29])

        #expect(Streak.best(of: gym, today: today, firstWeekday: monday) == 3)
    }

    @Test(arguments: [
        (1, DayState.done),
        (2, .skipped),
        (3, .missed),
        (0, .empty), // today, not done yet
        (40, .empty), // before the habit existed
        (-1, .empty), // tomorrow
    ])
    func eachDayHasOneState(daysAgo: Int, state: DayState) {
        let habit = habit(done: [1], skipped: [2])

        #expect(DayState(of: habit, on: today - daysAgo, today: today) == state)
    }

    @Test func aDayWithoutAWeeklyHabitIsNotAMiss() {
        #expect(DayState(of: habit(.timesPerWeek(3), done: []), on: today - 3, today: today) == .empty)
    }

    /// Offsets as `List.onMove` gives them: the destination counts the moved row in place.
    @Test(arguments: [
        (0, 2, ["B", "A", "C"]),
        (0, 3, ["B", "C", "A"]),
        (2, 0, ["C", "A", "B"]),
    ])
    func movingAHabitChangesTheGridOrder(from: Int, to: Int, expected: [String]) {
        let store = HabitsStore(url: .temporaryDirectory.appending(path: "StatisticsTests-\(UUID().uuidString).json"))
        let model = HabitsModel(store: store)
        for title in ["A", "B", "C"] {
            model.add(title: title, symbol: "book")
        }

        model.move(fromOffsets: [from], toOffset: to)

        #expect(model.todayHabits.map(\.title) == expected)
        #expect(HabitsModel(store: store).habits.map(\.title) == expected)
    }

    @Test func noonFallsOnTheSameCalendarDay() throws {
        var losAngeles = Calendar(identifier: .gregorian)
        losAngeles.timeZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
        let noon = LogicalDay(ordinal: 20_373).noon(in: losAngeles)

        #expect(LogicalDay(noon, calendar: losAngeles).ordinal == 20_373)
    }
}
