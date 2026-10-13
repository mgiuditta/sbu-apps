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
        (.cyclingDistance, 12_000, "12 km", "12 km"),
        (.swimmingDistance, 1_500, "1500 m", "1,500 m"),
        (.flightsClimbed, 1, "1 piano", "1 flight"),
        (.flightsClimbed, 10, "10 piani", "10 flights"),
        (.exerciseMinutes, 30, "30 min", "30 min"),
        (.standMinutes, 60, "60 min", "60 min"),
        (.timeInDaylight, 45, "45 min", "45 min"),
        (.sleep, 480, "8 h", "8 hr"),
        (.sleep, 450, "7 h e 30 min", "7 hr, 30 min"),
        (.activityRings, 1, "1 anello", "1 ring"),
        (.activityRings, 3, "3 anelli", "3 rings"),
    ])
    func goalsReadInTheUsersUnits(measure: HealthMeasure, amount: Double, italian: String, american: String) {
        #expect(measure.formatted(amount, locale: Locale(identifier: "it_IT")) == italian)
        #expect(measure.formatted(amount, locale: Locale(identifier: "en_US")) == american)
    }

    @Test(arguments: [
        (HealthMeasure.cyclingDistance, 1_000.0...200_000, 1_000.0, 10_000.0),
        (.swimmingDistance, 100...10_000, 100, 1_000),
        (.flightsClimbed, 1...100, 1, 10),
        (.exerciseMinutes, 5...240, 5, 30),
        (.standMinutes, 5...600, 5, 60),
        (.timeInDaylight, 5...480, 5, 30),
        (.sleep, 240...720, 30, 480),
        (.activityRings, 1...3, 1, 3),
    ])
    func theNewMeasuresOfferTheirGoals(measure: HealthMeasure, range: ClosedRange<Double>, step: Double, start: Double) {
        #expect(measure.goalRange == range)
        #expect(measure.goalStep == step)
        #expect(measure.defaultGoal == start)
    }

    @Test(arguments: HealthMeasure.allCases)
    func everyMeasureHasTheNameSaluteUsesInBothLanguages(measure: HealthMeasure) {
        var title = measure.title
        title.locale = Locale(identifier: "it_IT")
        let italian = String(localized: title)
        title.locale = Locale(identifier: "en_US")
        #expect(italian != String(localized: title), "\(italian) has no English")
    }

    @Test(arguments: HealthMeasure.allCases)
    func aGoalOutsideTheRangeIsKeptInside(measure: HealthMeasure) {
        #expect(HealthLink(measure: measure, goal: 0).goal == measure.goalRange.lowerBound)
        #expect(HealthLink(measure: measure, goal: 1_000_000).goal == measure.goalRange.upperBound)
    }

    @Test(arguments: HealthMeasure.allCases)
    func aLinkSurvivesTheFile(measure: HealthMeasure) throws {
        let link = HealthLink(measure: measure, goal: measure.defaultGoal)
        let decoded = try JSONDecoder().decode(HealthLink.self, from: JSONEncoder().encode(link))
        #expect(decoded == link)
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
