import Foundation
import Testing
@testable import SbuHabits

/// Salute's background delivery, driven by the fake: what the app does when HealthKit wakes it.
struct HealthBackgroundTests {
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "HealthBackgroundTests-\(UUID().uuidString).json"))
    private let health = FakeHealth()
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: hour))!
    }

    private func steps(_ amount: Double, at hour: Int) -> FakeHealth.Sample {
        FakeHealth.Sample(measure: .steps, date: date(hour), amount: amount)
    }

    @Test func withNoLinkedHabitNothingIsFollowed() {
        let model = HabitsModel(store: store, now: { date(20) }, calendar: calendar, scheduleReminders: { _ in }, health: health)
        model.add(title: "Leggere", symbol: "book")

        model.observeHealth()

        #expect(health.observed == [[]])
    }

    @Test func linkingAHabitStartsFollowingItsMeasureAndUnlinkingStops() {
        let model = HabitsModel(store: store, now: { date(20) }, calendar: calendar, scheduleReminders: { _ in }, health: health)
        model.observeHealth()

        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        model.delete(model.habits[1])

        #expect(health.observed == [[], [.steps], []])
    }

    @Test func newDataMarksTheHabitAndSavesItForTheWidget() async throws {
        let model = HabitsModel(store: store, now: { date(20) }, calendar: calendar, scheduleReminders: { _ in }, health: health)
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        model.observeHealth()

        await health.deliver(steps(8_000, at: 18))

        #expect(model.habits[0].isDone(on: model.today))
        #expect(try store.load().habits[0].isDone(on: model.today))
    }

    @Test func todaysRemindersGoOnceSaluteMarksTheHabit() async {
        var plans: [[PlannedReminder]] = []
        let model = HabitsModel(store: store, now: { date(20) }, calendar: calendar, scheduleReminders: { plans.append($0) }, health: health)
        model.add(title: "Camminare", symbol: "figure.walk", reminders: [ReminderTime(hour: 21, minute: 0)], health: HealthLink(measure: .steps, goal: 8_000))
        model.observeHealth()
        let tonight = date(21)
        #expect(plans.last?.contains { $0.date == tonight } == true)

        await health.deliver(steps(9_000, at: 18))

        #expect(plans.last?.contains { $0.date == tonight } == false)
        #expect(plans.last?.isEmpty == false)
    }

    @Test func aMarkFromTheWidgetMeanwhileIsKept() async throws {
        let model = HabitsModel(store: store, now: { date(20) }, calendar: calendar, scheduleReminders: { _ in }, health: health)
        model.add(title: "Leggere", symbol: "book")
        model.add(title: "Camminare", symbol: "figure.walk", health: HealthLink(measure: .steps, goal: 8_000))
        model.observeHealth()
        // The widget marks Leggere in the shared file while the app sleeps.
        _ = try MarkHabitIntent.mark(model.habits[0].id.uuidString, in: store, now: date(20), calendar: calendar)

        await health.deliver(steps(8_000, at: 18))

        let saved = try store.load().habits
        #expect(saved.allSatisfy { $0.isDone(on: model.today) })
    }
}
