import Foundation
import SwiftData
import Testing
@testable import SbuSubscriptions

struct SubscriptionDraftTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test(arguments: [
        ("it_IT", "12,99", "12.99"),
        ("it_IT", "1.234,5", "1234.5"),
        ("en_US", "12.99", "12.99"),
        ("en_US", "1,234.50", "1234.5"),
        ("it_IT", "0", "0"),
    ])
    func priceIsReadInYourLanguage(locale: String, text: String, expected: String) {
        var draft = SubscriptionDraft(currencyCode: "EUR")
        draft.locale = Locale(identifier: locale)
        draft.priceText = text
        #expect(draft.price == Decimal(string: expected))
    }

    @Test(arguments: ["", "  ", "abc", "-5"])
    func unreadablePriceCannotBeSaved(text: String) {
        var draft = SubscriptionDraft(currencyCode: "EUR")
        draft.name = "Musica"
        draft.priceText = text
        #expect(draft.price == nil)
        #expect(!draft.canSave)
    }

    @Test(arguments: [BillingCycle.weekly, .monthly, .every(3, .month), .yearly, .every(2, .week), .every(10, .day), .once])
    func cycleRoundTrips(cycle: BillingCycle) {
        var draft = SubscriptionDraft(currencyCode: "EUR")
        draft.cycle = cycle
        #expect(draft.cycle == cycle)
    }

    @Test func trialStartsTheScheduleWhenItEnds() throws {
        var draft = SubscriptionDraft(currencyCode: "EUR", today: day(2026, 10, 14), calendar: calendar)
        draft.name = "Corso"
        draft.priceText = "9,99"
        draft.locale = Locale(identifier: "it_IT")
        draft.hasTrial = true
        draft.trialEnd = day(2026, 10, 21)
        let subscription = try #require(draft.makeSubscription())
        #expect(subscription.startDate == day(2026, 10, 21))
        #expect(subscription.trialEndDate == day(2026, 10, 21))
        #expect(subscription.isInTrial(on: day(2026, 10, 14), in: calendar))
    }

    @Test func fixedCountIsIgnoredForOneOff() throws {
        var draft = SubscriptionDraft(currencyCode: "EUR")
        draft.name = "Concerto"
        draft.priceText = "50"
        draft.cycle = .once
        draft.hasFixedCount = true
        #expect(try #require(draft.makeSubscription()).paymentCount == nil)
    }

    @Test(arguments: [("sbu.dev/abbonamenti", "https://sbu.dev/abbonamenti"), ("https://example.com", "https://example.com"), ("", nil)])
    func websiteGetsAScheme(text: String, expected: String?) throws {
        var draft = SubscriptionDraft(currencyCode: "EUR")
        draft.name = "Musica"
        draft.priceText = "1"
        draft.urlText = text
        #expect(try #require(draft.makeSubscription()).url?.absoluteString == expected)
    }

    @Test func catalogServiceFillsNameCycleAndCategory() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        try CategorySeeder.seed(context)
        let categories = try context.fetch(FetchDescriptor<SubscriptionCategory>())
        let service = CatalogService(id: "duolingo", name: "Super Duolingo", category: .education, cycle: .yearly)
        let draft = SubscriptionDraft(service: service, categories: categories, currencyCode: "EUR")
        #expect(draft.name == "Super Duolingo")
        #expect(draft.cycle == .yearly)
        #expect(draft.category?.key == "education")
        #expect(draft.serviceID == "duolingo")
    }
}
