import Foundation
import Testing
@testable import SbuSubscriptions

struct HomeOptionsTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func make(_ name: String, _ price: Decimal, start: Date, cycle: BillingCycle = .monthly) -> Subscription {
        Subscription(name: name, price: price, currencyCode: "EUR", startDate: start, cycle: cycle)
    }

    @Test func sortsByNameAndByMonthlyPrice() {
        let yearly = make("Zeta", 120, start: day(2026, 1, 20), cycle: .yearly)  // 10 a month
        let weekly = make("Alfa", 5, start: day(2026, 10, 15), cycle: .weekly)    // ~21.67 a month
        let monthly = make("Beta", 12, start: day(2026, 1, 16))                   // 12 a month
        let all = [yearly, weekly, monthly]
        let today = day(2026, 10, 14)
        #expect(SubscriptionGroups(all, on: today, sort: .nextPayment, in: calendar).active.map(\.name) == ["Alfa", "Beta", "Zeta"])
        #expect(SubscriptionGroups(all, on: today, sort: .name, in: calendar).active.map(\.name) == ["Alfa", "Beta", "Zeta"])
        let byPrice = SubscriptionGroups(all, on: today, sort: .monthlyPrice, monthlyPrice: { $0.charge.amount(per: .month) }, in: calendar)
        #expect(byPrice.active.map(\.name) == ["Alfa", "Beta", "Zeta"])
        let cheapFirst = [make("Caro", 50, start: day(2026, 1, 20)), make("Economico", 1, start: day(2026, 1, 15))]
        #expect(SubscriptionGroups(cheapFirst, on: today, sort: .monthlyPrice, monthlyPrice: { $0.charge.amount(per: .month) }, in: calendar).active.map(\.name) == ["Caro", "Economico"])
    }

    @Test func groupsByCycleInOrder() {
        let groups = HomeSections.groups([make("A", 1, start: .now, cycle: .yearly), make("B", 1, start: .now), make("C", 1, start: .now, cycle: .yearly)], by: .cycle)
        #expect(groups.count == 2)
        #expect(groups.first { $0.subscriptions.count == 2 }?.subscriptions.map(\.name) == ["A", "C"])
    }

    @Test func filterMatchesListCategoryAndMethod() {
        let family = SubscriptionList(name: "Famiglia", order: 0)
        let music = SubscriptionCategory(customName: "Musica", symbol: "music.note", order: 0)
        let subscription = make("Spotify", 10, start: .now)
        subscription.list = family
        subscription.category = music
        subscription.paymentMethod = "Carta"
        #expect(HomeFilter().matches(subscription))
        #expect(HomeFilter(list: "Famiglia").matches(subscription))
        #expect(!HomeFilter(list: "Lavoro").matches(subscription))
        #expect(HomeFilter(category: "Musica", paymentMethod: "Carta").matches(subscription))
        #expect(!HomeFilter(paymentMethod: "PayPal").matches(subscription))
    }
}
