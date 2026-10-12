import Foundation
import Testing
@testable import SbuHabits

struct HealthMeasureTests {
    private let store = HabitsStore(url: .temporaryDirectory.appending(path: "HealthMeasureTests-\(UUID().uuidString).json"))
    private let health = FakeHealth()
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }

    @Test(arguments: HealthMeasure.allCases)
    func eachMeasureMarksItsHabitAtTheGoal(measure: HealthMeasure) async {
        let model = HabitsModel(store: store, now: { date(13, 21) }, calendar: calendar, scheduleReminders: { _ in }, health: health)
        let goal = measure.defaultGoal
        model.add(title: "Salute", symbol: "figure.walk", health: HealthLink(measure: measure, goal: goal))
        // Split in two, as a day's samples are; another measure's data never counts.
        health.samples = [
            FakeHealth.Sample(measure: measure, date: date(13, 9), amount: goal / 2),
            FakeHealth.Sample(measure: measure, date: date(13, 18), amount: goal / 2 - 1),
            FakeHealth.Sample(measure: measure == .steps ? .water : .steps, date: date(13, 10), amount: 100_000),
        ]

        await model.refreshFromHealth()
        #expect(model.habits[0].isDone(on: model.today) == false)

        health.samples.append(FakeHealth.Sample(measure: measure, date: date(13, 20), amount: 1))
        await model.refreshFromHealth()
        #expect(model.habits[0].isDone(on: model.today))
    }

    @Test(arguments: HealthMeasure.allCases)
    func theStartingGoalIsOneTheFormOffers(measure: HealthMeasure) {
        #expect(measure.goalRange.contains(measure.defaultGoal))
        #expect(measure.defaultGoal.truncatingRemainder(dividingBy: measure.goalStep) == 0)
        #expect(measure.goalRange.lowerBound.truncatingRemainder(dividingBy: measure.goalStep) == 0)
    }

    @Test(arguments: [
        (HealthMeasure.water, 2_000.0, "2000 ml", "2,000 mL"),
        (.mindfulMinutes, 10, "10 min", "10 min"),
        (.walkingRunningDistance, 5_500, "5,5 km", "5.5 km"),
        (.activeEnergy, 400, "400 kcal", "400 kcal"),
    ])
    func goalsReadInTheUsersUnits(measure: HealthMeasure, amount: Double, italian: String, american: String) {
        #expect(measure.formatted(amount, locale: Locale(identifier: "it_IT")) == italian)
        #expect(measure.formatted(amount, locale: Locale(identifier: "en_US")) == american)
    }

    @Test func stepsReadAsAGroupedNumber() {
        #expect(HealthMeasure.steps.formatted(12_000, locale: Locale(identifier: "en_US")).contains("12,000"))
    }

    // MARK: Mindful minutes

    @Test func aSessionAcrossTheStartOfTheDayCountsOnlyItsPartInside() {
        let day = DateInterval(start: date(13, 4), end: date(14, 4))
        let sessions = [
            DateInterval(start: date(13, 3, 50), end: date(13, 4, 10)),
            DateInterval(start: date(13, 12), end: date(13, 12, 15)),
        ]

        #expect(MindfulMinutes.total(of: sessions, within: day) == 25)
    }

    @Test func aSessionLoggedTwiceCountsOnce() {
        let day = DateInterval(start: date(13, 0), end: date(14, 0))
        let sessions = [
            DateInterval(start: date(13, 8), end: date(13, 8, 10)),
            DateInterval(start: date(13, 8, 5), end: date(13, 8, 20)),
            DateInterval(start: date(13, 8), end: date(13, 8, 10)),
        ]

        #expect(MindfulMinutes.total(of: sessions, within: day) == 20)
    }

    @Test func sessionsOnOtherDaysCountNothing() {
        let day = DateInterval(start: date(13, 0), end: date(14, 0))

        #expect(MindfulMinutes.total(of: [DateInterval(start: date(12, 20), end: date(12, 21))], within: day) == 0)
    }
}
