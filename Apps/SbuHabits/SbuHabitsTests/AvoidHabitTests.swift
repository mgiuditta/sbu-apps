import Foundation
import Testing
@testable import SbuHabits

struct AvoidHabitTests {
    private let today = LogicalDay(ordinal: 1_004) // a Sunday

    /// An Abitudine da evitare created 30 days ago, given in on the given days ago (0 is today).
    private func coffee(limit: Int = 2, given: [Int: Int]) -> Habit {
        var habit = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: limit, createdOn: today - 30)
        for (daysAgo, times) in given {
            habit.log[today - daysAgo] = times
        }
        return habit
    }

    @Test(arguments: [
        ([Int: Int](), 30), // never gave in: every past day counts, today not yet
        ([1: 2, 2: 1], 30), // within the limit
        ([0: 2], 30), // at the limit today: today breaks nothing
        ([0: 3], 0), // over the limit today: broken at once
        ([1: 3], 0), // over yesterday
        ([3: 5], 2), // over three days ago
    ])
    func serieCountsDaysWithinTheLimit(given: [Int: Int], expected: Int) {
        #expect(Streak.current(of: coffee(given: given), today: today, firstWeekday: 2) == expected)
    }

    @Test(arguments: [(0, 0, true), (0, 1, false), (2, 2, true), (2, 3, false)])
    func aDayIsDoneWithinTheLimit(limit: Int, times: Int, isDone: Bool) {
        let habit = coffee(limit: limit, given: [1: times])

        #expect(habit.isDone(on: today - 1) == isDone)
        #expect(DayState(of: habit, on: today - 1, today: today) == (isDone ? .done : .missed))
    }

    @Test(arguments: [
        (1, [0], 1, 1), // reading done today, coffee within: today counts
        (1, [Int](), 1, 0), // reading not done yet: today does not count, yesterday missed reading
        (1, [0, 1], 1, 31), // before reading existed, coffee alone counts
        (3, [0, 1], 1, 0), // coffee over the limit today
        (1, [0, 1], 3, 1), // coffee over the limit yesterday
    ])
    func seriePienaTreatsTheLimitAsDone(coffeeToday: Int, readDaysAgo: [Int], coffeeYesterday: Int, expected: Int) {
        let coffee = coffee(given: [0: coffeeToday, 1: coffeeYesterday])
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: today - 1)
        for daysAgo in readDaysAgo {
            reading.log[today - daysAgo] = 1
        }

        #expect(Streak.full(of: [coffee, reading], today: today) == expected)
    }

    @Test func todayWithinTheLimitIsNotDoneYet() {
        let habit = coffee(given: [0: 1])

        #expect(DayState(of: habit, on: today, today: today) == .empty)
        #expect(DayState(of: coffee(given: [0: 3]), on: today, today: today) == .missed)
    }

    @Test func bestSerieStopsAtTheDayOverTheLimit() {
        #expect(Streak.best(of: coffee(given: [10: 3]), today: today, firstWeekday: 2) == 20)
    }

    @Test func markingCountsEveryTimeGivenInPastTheLimit() {
        var habit = coffee(limit: 1, given: [:])
        for _ in 0..<3 {
            habit.mark(on: today, hour: 9)
        }
        let progress = HabitProgress(of: habit, today: today, firstWeekday: 2)

        #expect(habit.count(on: today) == 3)
        #expect(progress.isOverLimit)
        #expect(progress.holdUndoes == false)
        #expect(progress.margin == 0)
    }

    @Test func progressShowsTheMarginLeft() {
        let progress = HabitProgress(of: coffee(given: [0: 1]), today: today, firstWeekday: 2)

        #expect(progress.limit == 2)
        #expect(progress.margin == 1)
        #expect(progress.isComplete)
    }

    @Test func editingTheLimitKeepsThePast() {
        var habit = coffee(limit: 2, given: [1: 2])

        let isUpdated = habit.update(title: "Caffè", symbol: "cup.and.saucer", timesPerDay: 1, schedule: .everyDay, limit: 1, from: today)

        #expect(isUpdated)

        #expect(habit.limit == 1)
        #expect(habit.isDone(on: today - 1))
        #expect(habit.limit(on: today - 1) == 2)
    }

    @Test func theKindNeverChanges() {
        var avoided = coffee(given: [:])
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: today)

        _ = avoided.update(title: "Caffè", symbol: "cup.and.saucer", timesPerDay: 1, schedule: .everyDay, limit: nil, from: today)
        _ = reading.update(title: "Leggere", symbol: "book", timesPerDay: 1, schedule: .everyDay, limit: 2, from: today)

        #expect(avoided.limit == 2)
        #expect(reading.limit == nil)
    }

    @Test func anAvoidedHabitHasNoRemindersAndNoWeeklySchedule() {
        var habit = coffee(given: [:])

        _ = habit.update(title: "Caffè", symbol: "cup.and.saucer", timesPerDay: 1, schedule: .timesPerWeek(3), limit: 2, reminders: [ReminderTime(hour: 9, minute: 0)], from: today)

        #expect(habit.schedule == .everyDay)
        #expect(habit.reminders.isEmpty)
    }

    @Test func aFileFromThePreviousVersionOpensAsHabitsToDo() throws {
        let json = #"""
        {"version":1,"startHour":0,"habits":[{"id":"6F9619FF-8B86-D011-B42D-00C04FC964FF","title":"Leggere","symbol":"book",
        "timesPerDay":2,"schedule":{"everyDay":{}},"createdOn":990,"log":{"1000":2},"skipped":[],"reminders":[],
        "earlier":[{"until":995,"timesPerDay":1,"schedule":{"everyDay":{}}}]}]}
        """#

        let file = try JSONDecoder().decode(HabitsFile.self, from: Data(json.utf8))
        let habit = try #require(file.habits.first)

        #expect(habit.limit == nil)
        #expect(habit.limit(on: LogicalDay(ordinal: 992)) == nil)
        #expect(habit.timesPerDay(on: LogicalDay(ordinal: 992)) == 1)
        #expect(habit.isDone(on: LogicalDay(ordinal: 1_000)))
        #expect(habit.count(on: LogicalDay(ordinal: 1_000)) == 2)
    }

    @Test func theLimitSurvivesSaving() throws {
        var habit = coffee(given: [1: 1])
        _ = habit.update(title: "Caffè", symbol: "cup.and.saucer", timesPerDay: 1, schedule: .everyDay, limit: 0, from: today)
        let file = HabitsFile(habits: [habit])

        let decoded = try JSONDecoder().decode(HabitsFile.self, from: JSONEncoder().encode(file))

        #expect(decoded == file)
    }
}
