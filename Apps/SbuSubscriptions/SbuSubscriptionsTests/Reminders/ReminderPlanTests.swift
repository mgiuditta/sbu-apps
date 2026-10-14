import Foundation
import Testing
@testable import SbuSubscriptions

struct ReminderPlanTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    func source(_ id: String = "a", start: Date, cycle: BillingCycle = .monthly, daysBefore: Int? = 1, trialEnd: Date? = nil, active: Bool = true) -> ReminderSource {
        ReminderSource(id: id, name: id, price: 10, currencyCode: "EUR", schedule: BillingSchedule(start: start, cycle: cycle),
                       trialEnd: trialEnd, daysBefore: daysBefore, isActive: active)
    }

    func plan(_ sources: [ReminderSource], now: Date, limit: Int = ReminderPlan.limit) -> [PlannedReminder] {
        ReminderPlan.reminders(for: sources, hour: 9, minute: 0, after: now, calendar: calendar, limit: limit)
    }

    @Test func remindsTheChosenDaysBeforeAtTheChosenTime() throws {
        let first = try #require(plan([source(start: day(2026, 1, 20), daysBefore: 3)], now: day(2026, 10, 14, hour: 12)).first)
        #expect(first.paymentDate == day(2026, 10, 20))
        #expect(first.fireDate == day(2026, 10, 17, hour: 9))
        #expect(first.kind == .renewal)
    }

    @Test func aReminderWhoseTimeHasPassedIsSkipped() throws {
        // Payment tomorrow, reminder was due today at 9: at noon it's gone, the next month's comes first.
        let first = try #require(plan([source(start: day(2026, 1, 15))], now: day(2026, 10, 14, hour: 12)).first)
        #expect(first.paymentDate == day(2026, 11, 15))
    }

    @Test func stoppedOrUnremindedSubscriptionsGetNothing() {
        let now = day(2026, 10, 14)
        #expect(plan([source(start: day(2026, 1, 20), active: false)], now: now).isEmpty)
        #expect(plan([source(start: day(2026, 1, 20), daysBefore: nil)], now: now).isEmpty)
    }

    @Test func trialEndReplacesItsFirstRenewal() {
        let reminders = plan([source(start: day(2026, 10, 21), trialEnd: day(2026, 10, 21))], now: day(2026, 10, 14))
        #expect(reminders.first?.kind == .trialEnds)
        #expect(reminders.first?.paymentDate == day(2026, 10, 21))
        #expect(reminders.dropFirst().allSatisfy { $0.kind == .renewal && $0.paymentDate > day(2026, 10, 21) })
    }

    @Test func neverMoreThanTheLimitAndTheNearestFirst() {
        let sources = (0..<10).map { source("s\($0)", start: day(2026, 1, 1 + $0), cycle: .weekly) }
        let reminders = plan(sources, now: day(2026, 10, 14))
        #expect(reminders.count == ReminderPlan.limit)
        #expect(reminders.map(\.fireDate) == reminders.map(\.fireDate).sorted())
    }

    @Test func instalmentsStopAtTheLastPayment() {
        var plan3 = source(start: day(2026, 11, 1))
        plan3.schedule.paymentCount = 3
        #expect(plan([plan3], now: day(2026, 10, 14)).count == 3)
    }

    @Test(arguments: [PlannedReminder.Kind.renewal, .trialEnds], [0, 1, 3])
    func textSaysTheAmountAndTheDay(kind: PlannedReminder.Kind, daysBefore: Int) {
        let reminder = PlannedReminder(kind: kind, subscriptionID: "a", name: "Musica", price: 10, currencyCode: "EUR",
                                       paymentDate: day(2026, 10, 20), daysBefore: daysBefore, fireDate: day(2026, 10, 17, hour: 9))
        // The sentence follows the app's language; amount and date follow the locale passed in.
        let body = ReminderText.body(for: reminder, locale: Locale(identifier: "it_IT"))
        #expect(body.contains("10,00"))
        #expect(body.contains("20 ottobre") == (daysBefore > 1))
    }
}
