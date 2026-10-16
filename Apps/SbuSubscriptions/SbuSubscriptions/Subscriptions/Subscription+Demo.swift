import Foundation
import SwiftData

extension Subscription {
    /// Made-up subscriptions for previews and the App Store screenshots, never real services.
    static func demo(today: Date = .now, calendar: Calendar = .current) -> [Subscription] {
        func day(_ offset: Int) -> Date { calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: today)) ?? today }
        func make(_ name: String.LocalizationValue, _ price: String, _ currency: String = "EUR", start: Int, _ cycle: BillingCycle = .monthly) -> Subscription {
            Subscription(name: String(localized: name), price: Decimal(string: price) ?? 0, currencyCode: currency, startDate: day(start), cycle: cycle)
        }
        let trial = make("Corso di lingue", "9.99", start: 5)
        trial.trialEndDate = day(5)
        let paused = make("Palestra", "39", start: -200)
        paused.status = .paused
        // Paid for over a year, so its detail has a history to show.
        let music = make("Musica", "10.99", start: -58)
        music.startDate = calendar.date(byAdding: .year, value: -1, to: music.startDate) ?? music.startDate
        return [
            make("Film e serie", "13.99", start: -40),
            music,
            make("Archivio cloud", "2.99", start: -20),
            make("Giornale", "79.99", start: -300, .yearly),
            make("Strumenti di design", "12", "USD", start: -27),
            trial,
            paused,
        ]
    }

    static var preview: Subscription { demo()[0] }
}

extension ModelContainer {
    /// An in-memory store filled with `Subscription.demo`.
    static var preview: ModelContainer {
        // ponytail: in-memory never fails to open; a crash here is a broken preview, not lost data.
        let container = try! subscriptions(inMemory: true)
        try? CategorySeeder.seed(container.mainContext)
        let categories = (try? container.mainContext.fetch(FetchDescriptor<SubscriptionCategory>())) ?? []
        let keys: [BuiltInCategory] = [.streaming, .music, .cloud, .news, .design, .education, .fitness]
        for (subscription, key) in zip(Subscription.demo(), keys) {
            subscription.category = categories.first { $0.key == key.rawValue }
            container.mainContext.insert(subscription)
        }
        return container
    }
}
