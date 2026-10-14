import Foundation
import SwiftData

extension Subscription {
    /// Made-up subscriptions for previews and the App Store screenshots, never real services.
    static func demo(today: Date = .now, calendar: Calendar = .current) -> [Subscription] {
        func day(_ offset: Int) -> Date { calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: today)) ?? today }
        func make(_ name: String, _ price: String, _ currency: String = "EUR", start: Int, _ cycle: BillingCycle = .monthly) -> Subscription {
            Subscription(name: name, price: Decimal(string: price) ?? 0, currencyCode: currency, startDate: day(start), cycle: cycle)
        }
        let trial = make("Corso di lingue", "9.99", start: 5)
        trial.trialEndDate = day(5)
        let paused = make("Palestra", "39", start: -200)
        paused.status = .paused
        return [
            make("Film e serie", "13.99", start: -40),
            make("Musica", "10.99", start: -58),
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
        Subscription.demo().forEach(container.mainContext.insert)
        return container
    }
}
