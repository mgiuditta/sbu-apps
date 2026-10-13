import Foundation
import Testing
@testable import SbuHabits

struct HealthTests {
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "HealthTests-\(UUID().uuidString).json"))
    private let health = FakeHealth()
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    private func model(at now: Date) -> HabitsModel {
        HabitsModel(store: store, now: { now }, calendar: calendar, scheduleReminders: { _ in }, health: health)
    }

    private func steps(_ amount: Double, at date: Date) -> FakeHealth.Sample {
        FakeHealth.Sample(measure: .steps, date: date, amount: amount)
    }

    // MARK: The logical day

    @Test func aLogicalDayRunsFromItsStartHourToTheNextOne() {
        let day = LogicalDay(date(2026, 10, 13, 12), calendar: calendar)

        let interval = day.interval(startHour: 4, in: calendar)

        #expect(interval.start == date(2026, 10, 13, 4))
        #expect(interval.end == date(2026, 10, 14, 4))
    }

    @Test func theDayClocksGoForwardLastsTwentyThreeHours() {
        let day = LogicalDay(date(2026, 3, 29, 12), calendar: calendar)

        #expect(day.interval(startHour: 0, in: calendar).duration == 23 * 3_600)
    }

    @Test func stepsBeforeTheStartOfTheDayCountForTheDayBefore() async {
        // 02:00 on the 13th with a day starting at 4 is still the 12th.
        let model = model(at: date(2026, 10, 13, 2))
        model.setStartHour(4)
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        health.samples = [
            steps(5_000, at: date(2026, 10, 12, 10)),
            steps(3_000, at: date(2026, 10, 13, 1)),
            steps(9_000, at: date(2026, 10, 13, 5)),
        ]

        await model.refreshFromHealth()

        #expect(health.intervals == [DateInterval(start: date(2026, 10, 12, 4), end: date(2026, 10, 13, 4))])
        #expect(model.habits[0].isDone(on: model.today))
    }

    // MARK: The goal

    @Test(arguments: [(7_999.0, false), (8_000.0, true), (12_000.0, true)])
    func aLinkedHabitIsDoneOnceTheGoalIsReached(total: Double, isDone: Bool) async {
        let model = model(at: date(2026, 10, 13, 20))
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        health.samples = [steps(total, at: date(2026, 10, 13, 9))]

        await model.refreshFromHealth()

        #expect(model.habits[0].isDone(on: model.today) == isDone)
        #expect(model.fullStreak == (isDone ? 1 : 0))
    }

    @Test func theMarkIsSavedForTheWidget() async throws {
        let model = model(at: date(2026, 10, 13, 20))
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        health.samples = [steps(8_000, at: date(2026, 10, 13, 9))]

        await model.refreshFromHealth()

        #expect(try store.load().habits[0].isDone(on: model.today))
    }

    @Test func aDeniedMeasureLeavesTheHabitToBeMarkedByHand() async {
        let model = model(at: date(2026, 10, 13, 20))
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        health.samples = [steps(10_000, at: date(2026, 10, 13, 9))]
        health.denied = [.steps]

        await model.refreshFromHealth()
        #expect(model.habits[0].isDone(on: model.today) == false)

        model.markDone(model.habits[0])
        #expect(model.habits[0].isDone(on: model.today))
    }

    @Test func saluteNeverTakesAMarkBack() async {
        let model = model(at: date(2026, 10, 13, 20))
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        model.markDone(model.habits[0])

        await model.refreshFromHealth()

        #expect(model.habits[0].isDone(on: model.today))
    }

    @Test func aSkippedDayStaysSkipped() async {
        let model = model(at: date(2026, 10, 13, 20))
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        model.toggleSkip(model.habits[0])
        health.samples = [steps(9_000, at: date(2026, 10, 13, 9))]

        await model.refreshFromHealth()

        #expect(model.habits[0].isSkipped(on: model.today))
        #expect(model.habits[0].count(on: model.today) == 0)
    }

    @Test func aDayTheHabitIsNotExpectedIsLeftAlone() {
        let today = LogicalDay(date(2026, 10, 13, 12), calendar: calendar)
        var habit = Habit(title: "Palestra", symbol: "figure.walk", createdOn: today - 7)
        _ = habit.update(title: "Palestra", symbol: "figure.walk", timesPerDay: 1, schedule: .weekdays([today.weekday % 7 + 1]), health: HealthLink(measure: .steps, goal: 8_000), from: today - 7)
        var habits = [habit]

        #expect(HealthMarking.mark(&habits, totals: [.steps: 9_000], on: today, hour: 9) == false)
        #expect(habits[0].count(on: today) == 0)
    }

    @Test func aWeeklyHabitCountsTheDayTheGoalIsReached() {
        let today = LogicalDay(date(2026, 10, 13, 12), calendar: calendar)
        var habit = Habit(title: "Corsa", symbol: "figure.walk", createdOn: today)
        _ = habit.update(title: "Corsa", symbol: "figure.walk", timesPerDay: 1, schedule: .timesPerWeek(3), health: HealthLink(measure: .steps, goal: 8_000), from: today)
        var habits = [habit]

        #expect(HealthMarking.mark(&habits, totals: [.steps: 9_000], on: today, hour: 9))
        #expect(habits[0].isDone(on: today))
    }

    @Test func noLinkedHabitAsksSaluteNothing() async {
        let model = model(at: date(2026, 10, 13, 20))
        model.add(title: "Leggere", symbol: "book")

        await model.refreshFromHealth()

        #expect(health.intervals.isEmpty)
        #expect(health.requested.isEmpty)
    }

    // MARK: Linking

    @Test func linkingAsksToReadOnlyThatMeasure() async {
        let model = model(at: date(2026, 10, 13, 20))
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        health.samples = [steps(8_000, at: date(2026, 10, 13, 9))]

        await model.connectHealth(.steps)

        #expect(health.requested == [[.steps]])
        #expect(model.habits[0].isDone(on: model.today))
    }

    @Test func aLinkedHabitIsDoneOnceADay() {
        let model = model(at: date(2026, 10, 13, 20))

        model.add(title: "Camminare", symbol: "figure.walk", timesPerDay: 5, health: HealthLink(measure: .steps, goal: 8_000))

        #expect(model.habits[0].timesPerDay == 1)
        #expect(model.linkedMeasures == [.steps])
    }

    @Test func aHabitToAvoidIsNeverLinked() {
        let model = model(at: date(2026, 10, 13, 20))

        model.add(title: "Caffè", symbol: "cup.and.saucer", limit: 2, health: HealthLink(measure: .steps, goal: 8_000))

        #expect(model.habits[0].health == nil)
        #expect(model.linkedMeasures.isEmpty)
    }

    @Test func editingCanTakeTheLinkAway() {
        let model = model(at: date(2026, 10, 13, 20))
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))

        model.edit(model.habits[0], title: "Camminare", symbol: "figure.walk", timesPerDay: 1, schedule: .everyDay)

        #expect(model.habits[0].health == nil)
    }

    @Test func aGoalStaysWithinTheFormsRange() {
        #expect(HealthLink(measure: .steps, goal: 10).goal == HealthMeasure.steps.goalRange.lowerBound)
        #expect(HealthLink(measure: .steps, goal: 1_000_000).goal == HealthMeasure.steps.goalRange.upperBound)
    }

    // MARK: The file

    @Test func habitsSavedBeforeSaluteLoadUnlinked() throws {
        let old = #"{"version": 1, "habits": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "title": "Leggere", "symbol": "book", "timesPerDay": 1, "schedule": {"everyDay": {}}, "createdOn": 20000, "log": {"20001": 1}, "skipped": [], "reminders": []}], "startHour": 4}"#

        let file = try JSONDecoder().decode(HabitsFile.self, from: Data(old.utf8))

        #expect(file.habits[0].health == nil)
        #expect(file.habits[0].isDone(on: LogicalDay(ordinal: 20_001)))
    }

    @Test func aLinkSurvivesAJSONRoundTrip() throws {
        var habit = Habit(title: "Camminare", symbol: "figure.walk", createdOn: LogicalDay(ordinal: 20_000))
        _ = habit.update(title: "Camminare", symbol: "figure.walk", timesPerDay: 1, schedule: .everyDay, health: HealthLink(measure: .steps, goal: 6_500), from: LogicalDay(ordinal: 20_000))
        let file = HabitsFile(habits: [habit])

        let decoded = try JSONDecoder().decode(HabitsFile.self, from: JSONEncoder().encode(file))

        #expect(decoded == file)
        #expect(decoded.habits[0].health == HealthLink(measure: .steps, goal: 6_500))
    }
}
