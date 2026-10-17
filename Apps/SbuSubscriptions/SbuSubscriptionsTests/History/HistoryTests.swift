import Foundation
import SwiftData
import Testing
@testable import SbuSubscriptions

struct HistoryTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    @Test func priceFollowsTheChangeFromItsDay() {
        let changes = [(date: day(2026, 11, 1), price: Decimal(12)), (date: day(2027, 3, 1), price: Decimal(15))]
        #expect(PriceTimeline.price(on: day(2026, 10, 31), base: 10, changes: changes, calendar: calendar) == 10)
        #expect(PriceTimeline.price(on: day(2026, 11, 1), base: 10, changes: changes, calendar: calendar) == 12)
        #expect(PriceTimeline.price(on: day(2027, 6, 1), base: 10, changes: changes, calendar: calendar) == 15)
    }

    @Test func pastPaymentsNewestFirst() {
        let schedule = BillingSchedule(start: day(2026, 1, 15), cycle: .monthly)
        #expect(PaymentHistory.past(schedule, through: day(2026, 4, 15), calendar: calendar) == [day(2026, 4, 15), day(2026, 3, 15), day(2026, 2, 15), day(2026, 1, 15)])
        #expect(PaymentHistory.past(schedule, through: day(2026, 1, 14), calendar: calendar).isEmpty)
        #expect(PaymentHistory.past(schedule, through: day(2028, 1, 1), limit: 3, calendar: calendar).count == 3)
        let once = BillingSchedule(start: day(2026, 1, 15), cycle: .once)
        #expect(PaymentHistory.past(once, through: day(2026, 6, 1), calendar: calendar) == [day(2026, 1, 15)])
    }

    @Test func futureRiseReachesTotalsCalendarAndRemindersOnlyFromItsDay() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        let subscription = Subscription(name: "Video", price: 10, currencyCode: "EUR", startDate: day(2026, 1, 20))
        context.insert(subscription)
        let rise = PriceChange(effectiveDate: day(2026, 12, 1), price: 12)
        context.insert(rise)
        rise.subscription = subscription
        try context.save()

        #expect(subscription.price(on: day(2026, 11, 20), calendar: calendar) == 10)
        #expect(subscription.price(on: day(2026, 12, 20), calendar: calendar) == 12)

        let converter = CurrencyConverter(table: ExchangeRates(day: "", perEuro: ["EUR": 1]))
        let december = MonthPayments([subscription], in: MonthGrid(containing: day(2026, 12, 1), calendar: calendar), today: day(2026, 10, 14),
                                     mainCurrency: "EUR", converter: converter, calendar: calendar)
        #expect(december.total == 12)

        let reminders = ReminderPlan.reminders(for: [subscription.reminderSource], hour: 9, minute: 0, after: day(2026, 10, 14), calendar: calendar)
        #expect(reminders.first { $0.paymentDate == day(2026, 11, 20) }?.price == 10)
        #expect(reminders.first { $0.paymentDate == day(2026, 12, 20) }?.price == 12)
    }

    @Test func settlingMakesAStartedChangeThePrice() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        let subscription = Subscription(name: "Video", price: 10, currencyCode: "EUR", startDate: day(2026, 1, 20))
        context.insert(subscription)
        let rise = PriceChange(effectiveDate: day(2026, 11, 1), price: 12)
        context.insert(rise)
        rise.subscription = subscription
        PriceSettler.settle([subscription], today: day(2026, 10, 31), calendar: calendar)
        #expect(subscription.price == 10)
        PriceSettler.settle([subscription], today: day(2026, 11, 1), calendar: calendar)
        #expect(subscription.price == 12)
    }

    @Test func spentSoFarKeepsTheOldPriceForPaymentsBeforeTheChange() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        let subscription = Subscription(name: "Video", price: 10, currencyCode: "EUR", startDate: day(2025, 1, 20))
        context.insert(subscription)
        subscription.changePrice(to: 12, from: day(2026, 1, 20), in: context, today: day(2026, 1, 20), calendar: calendar)

        #expect(subscription.price == 12)
        #expect(subscription.price(on: day(2025, 6, 20), calendar: calendar) == 10)
        // 12 payments at 10, then 2026-01-20 and 2026-02-20 at 12.
        #expect(subscription.tally(today: day(2026, 2, 20), calendar: calendar).spent == 144)
        subscription.changePrice(to: 15, from: day(2026, 3, 20), in: context, today: day(2026, 2, 20), calendar: calendar)
        #expect(subscription.priceChanges?.count == 3)
    }

    @Test func aChangeFromTheFirstPaymentAddsNoOldPrice() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        let subscription = Subscription(name: "Video", price: 10, currencyCode: "EUR", startDate: day(2026, 1, 20))
        context.insert(subscription)
        subscription.changePrice(to: 8, from: day(2026, 1, 20), in: context, today: day(2026, 1, 20), calendar: calendar)
        #expect(subscription.priceChanges?.count == 1)
        #expect(subscription.price == 8)
    }

    @Test func eventsAreKeptAndGoWithTheSubscription() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        let subscription = Subscription(name: "Video", price: 10, currencyCode: "EUR", startDate: day(2026, 1, 20))
        context.insert(subscription)
        subscription.record(.subscribed)
        subscription.record(.paid, date: day(2026, 9, 20), amount: 10)
        try context.save()
        #expect(subscription.events?.map(\.kind).sorted { $0.rawValue < $1.rawValue } == [.paid, .subscribed])
        context.delete(subscription)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<SubscriptionEvent>()) == 0, "Deleting a subscription deletes its history")
    }
}
