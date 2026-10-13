import Foundation
import Testing
@testable import SbuHabits

/// The hour of each mark, kept beside the log for the Statistiche curve.
struct CompletionHoursTests {
    private let today = LogicalDay(ordinal: 20_010)
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    private func store() -> HabitsStore {
        HabitsStore(url: .temporaryDirectory.appending(path: "CompletionHoursTests-\(UUID().uuidString).json"))
    }

    /// Reading at 7 and 22 on each of the last ten days, water once at 7 three days ago.
    private var habits: [Habit] {
        var reading = Habit(title: "Leggere", symbol: "book", timesPerDay: 2, createdOn: today - 30)
        for daysAgo in 0..<10 {
            reading.mark(on: today - daysAgo, hour: 7)
            reading.mark(on: today - daysAgo, hour: 22)
        }
        var water = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: today - 30)
        water.mark(on: today - 3, hour: 7)
        return [reading, water]
    }

    @Test(arguments: [
        (0, 0, 1, 1), // today only
        (6, 0, 8, 7), // the last seven days
        (29, 0, 11, 10), // further back than any mark
        (40, 20, 0, 0), // before any mark
    ])
    func eachMarkCountsInItsHour(fromDaysAgo: Int, toDaysAgo: Int, at7: Int, at22: Int) {
        let counts = CompletionHours.counts(of: habits, in: (today - fromDaysAgo)...(today - toDaysAgo))

        #expect(counts.count == 24)
        #expect(counts[7] == at7)
        #expect(counts[22] == at22)
        #expect(counts.reduce(0, +) == at7 + at22)
    }

    @Test func daysMarkedBeforeHoursExistedStayOut() {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today - 5)
        habit.log[today - 1] = 1
        habit.mark(on: today, hour: 8)

        #expect(CompletionHours.counts(of: [habit], in: (today - 5)...today).reduce(0, +) == 1)
    }

    @Test func undoTakesBackTheLastHour() {
        var habit = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 3, createdOn: today)
        habit.mark(on: today, hour: 8)
        habit.mark(on: today, hour: 12)

        habit.undoLast(on: today)
        #expect(habit.markHours[today] == [8])

        habit.undoLast(on: today)
        #expect(habit.markHours[today] == nil)
        #expect(habit.count(on: today) == 0)
    }

    @Test func undoOnADayMarkedBeforeHoursExistedOnlyLowersTheCount() {
        var habit = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 3, createdOn: today)
        habit.log[today] = 2

        habit.undoLast(on: today)

        #expect(habit.count(on: today) == 1)
        #expect(habit.markHours.isEmpty)
    }

    @Test func skippingClearsTheHours() {
        var habit = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 3, createdOn: today)
        habit.mark(on: today, hour: 8)

        habit.toggleSkip(on: today)

        #expect(habit.markHours[today] == nil)
    }

    @Test func aMarkPastTheGoalAddsNoHour() {
        var habit = Habit(title: "Leggere", symbol: "book", createdOn: today)
        habit.mark(on: today, hour: 8)
        habit.mark(on: today, hour: 9)

        #expect(habit.markHours[today] == [8])
    }

    @Test func saluteGivesTheMarkItAddsTheHour() {
        var habit = Habit(title: "Camminare", symbol: "figure.walk", createdOn: today)
        _ = habit.update(title: "Camminare", symbol: "figure.walk", timesPerDay: 1, schedule: .everyDay, health: HealthLink(measure: .steps, goal: 8_000), from: today)
        var habits = [habit]

        #expect(HealthMarking.mark(&habits, totals: [.steps: 9_000], on: today, hour: 18))
        #expect(habits[0].markHours[today] == [18])
    }

    @Test func aMarkAfterMidnightCountsForTheDayBeforeAtItsOwnHour() throws {
        // 01:30 on the 13th with a day starting at 4 is still the 12th, at hour 1.
        let store = store()
        let now = date(2026, 10, 13, 1, 30)
        let model = HabitsModel(store: store, now: { now }, calendar: calendar, scheduleReminders: { _ in })
        model.setStartHour(4)
        model.add(title: "Leggere", symbol: "book")
        let yesterday = LogicalDay(date(2026, 10, 12, 12), calendar: calendar)

        let file = try MarkHabitIntent.mark(model.habits[0].id.uuidString, in: store, now: now, calendar: calendar)

        #expect(file.habits[0].markHours == [yesterday: [1]])
        #expect(CompletionHours.counts(of: file.habits, in: yesterday...yesterday)[1] == 1)
    }

    @Test func theAppKeepsTheHourOnTheClockOfItsTimeZone() {
        let store = store()
        let now = date(2026, 10, 13, 21, 45)
        let model = HabitsModel(store: store, now: { now }, calendar: calendar, scheduleReminders: { _ in })
        model.add(title: "Leggere", symbol: "book")

        model.markDone(model.habits[0])

        #expect(HabitsModel(store: store, now: { now }, calendar: calendar, scheduleReminders: { _ in }).habits[0].markHours[model.today] == [21])
    }
}
