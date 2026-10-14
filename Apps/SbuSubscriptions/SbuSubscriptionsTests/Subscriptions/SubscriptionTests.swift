import Foundation
import SwiftData
import Testing
@testable import SbuSubscriptions

struct SubscriptionTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func storeKeepsEveryField() throws {
        let container = try ModelContainer.subscriptions(inMemory: true)
        let context = ModelContext(container)
        let subscription = Subscription(
            name: "Musica",
            price: Decimal(string: "10.99")!,
            currencyCode: "USD",
            startDate: day(2026, 1, 31),
            cycle: .every(3, .month),
            paymentCount: 4
        )
        subscription.trialEndDate = day(2026, 2, 7)
        subscription.status = .paused
        context.insert(subscription)
        try context.save()

        let stored = try #require(try ModelContext(container).fetch(FetchDescriptor<Subscription>()).first)
        #expect(stored.name == "Musica")
        #expect(stored.price == Decimal(string: "10.99"))
        #expect(stored.currencyCode == "USD")
        #expect(stored.cycle == .every(3, .month))
        #expect(stored.paymentCount == 4)
        #expect(stored.status == .paused)
        #expect(stored.trialEndDate == day(2026, 2, 7))
    }

    @Test(arguments: [SubscriptionStatus.paused, .cancelled])
    func stoppedSubscriptionHasNoNextPayment(status: SubscriptionStatus) {
        let subscription = Subscription(name: "Video", price: 8, currencyCode: "EUR", startDate: day(2026, 1, 1))
        subscription.status = status
        #expect(subscription.nextPayment(after: day(2026, 10, 14), in: calendar) == nil)
    }

    @Test func activeSubscriptionHasNextPayment() {
        let subscription = Subscription(name: "Video", price: 8, currencyCode: "EUR", startDate: day(2026, 1, 1))
        #expect(subscription.nextPayment(after: day(2026, 10, 14), in: calendar) == day(2026, 11, 1))
    }

    @Test func trialLastsUntilItsEndDay() {
        let subscription = Subscription(name: "Cloud", price: 3, currencyCode: "EUR", startDate: day(2026, 10, 21))
        subscription.trialEndDate = day(2026, 10, 21)
        #expect(subscription.isInTrial(on: day(2026, 10, 20), in: calendar))
        #expect(!subscription.isInTrial(on: day(2026, 10, 21), in: calendar))
    }
}

struct DuplicateIDTests {
    @Test func copiesGetNewIDsTheFirstKeepsItsOwn() throws {
        let context = ModelContext(try ModelContainer.subscriptions(inMemory: true))
        let shared = UUID()
        let first = Subscription(name: "A", price: 1, currencyCode: "EUR", startDate: .now)
        let second = Subscription(name: "B", price: 1, currencyCode: "EUR", startDate: .now)
        [first, second].forEach { $0.uuid = shared; context.insert($0) }
        try context.save()
        try Subscription.repairDuplicateIDs(context)
        let ids = try context.fetch(FetchDescriptor<Subscription>()).map(\.uuid)
        #expect(Set(ids).count == 2)
        #expect(ids.contains(shared))
    }
}
