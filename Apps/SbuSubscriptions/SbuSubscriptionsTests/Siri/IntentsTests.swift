import Foundation
import Testing
@testable import SbuSubscriptions

/// The answers Siri gives, from the subscriptions alone; the intents only read the store and speak them.
struct IntentsTests {
    let calendar = Calendar.current

    func inDays(_ days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: .now))!
    }

    @Test func countIgnoresPausedAndPaidOff() {
        let paused = Subscription(name: "Palestra", price: 30, currencyCode: "EUR", startDate: inDays(-40))
        paused.status = .paused
        let done = Subscription(name: "Corso", price: 10, currencyCode: "EUR", startDate: inDays(-100), cycle: .monthly, paymentCount: 2)
        let music = Subscription(name: "Musica", price: 10, currencyCode: "EUR", startDate: inDays(3))
        #expect(SubscriptionAnswers.count([music, paused, done]) == 1)
    }

    @Test func nextRenewalIsTheSoonestOrTheChosenOne() {
        let music = Subscription(name: "Musica", price: 10, currencyCode: "EUR", startDate: inDays(3))
        let video = Subscription(name: "Video", price: 8, currencyCode: "EUR", startDate: inDays(1))
        #expect(SubscriptionAnswers.nextRenewal([music, video])?.name == "Video")
        #expect(SubscriptionAnswers.nextRenewal([music, video], of: music.uuid)?.day == inDays(3))
        #expect(SubscriptionAnswers.nextRenewal([]) == nil)
    }

    @Test func searchByNameIgnoresCase() {
        let music = Subscription(name: "Musica", price: 10, currencyCode: "EUR", startDate: inDays(3))
        #expect(SubscriptionAnswers.matching("mus", in: [music]).map(\.name) == ["Musica"])
        #expect(SubscriptionAnswers.matching("video", in: [music]).isEmpty)
    }

    @Test func entityCarriesTheStableIdAndThePrice() {
        let music = Subscription(name: "Musica", price: 10, currencyCode: "EUR", startDate: inDays(3))
        let entity = SubscriptionEntity(music)
        #expect(entity.id == music.uuid)
        #expect(entity.name == "Musica")
        #expect(entity.priceText.contains("10"))
    }

    @Test func routerHoldsTheRouteUntilFollowed() {
        let router = AppRouter()
        router.open(.subscription(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!))
        #expect(router.pending == .subscription(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!))
    }

    @Test(arguments: [BillingCycle.monthly, .yearly, .every(2, .week), .once])
    func priceSentenceHasTheAmount(cycle: BillingCycle) {
        #expect(PriceText.text(10, currencyCode: "EUR", cycle: cycle).contains("10"))
    }
}

struct SpotlightPrivacyTests {
    @Test func spotlightShowsTheCycleNeverThePrice() {
        let subscription = Subscription(name: "Musica", price: Decimal(string: "10.99")!, currencyCode: "EUR", startDate: .now)
        let entity = SubscriptionEntity(subscription)
        let shown = String(localized: entity.displayRepresentation.subtitle ?? "")
        #expect(!shown.contains("10"), "What you pay never shows in Spotlight")
        #expect(!shown.isEmpty)
    }
}
