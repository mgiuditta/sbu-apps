import Foundation

/// Once a price change's day has come, its price becomes the subscription's own, so editing shows the real price.
enum PriceSettler {
    static func settle(_ subscriptions: [Subscription], today: Date = .now, calendar: Calendar = .current) {
        let day = calendar.startOfDay(for: today)
        for subscription in subscriptions {
            let current = subscription.price(on: day, calendar: calendar)
            if current != subscription.price { subscription.price = current }
        }
    }
}
