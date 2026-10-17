import Foundation

/// The prices a subscription has had, newest first, each from its day.
///
/// A price change, once its day comes, becomes the subscription's own price (`PriceSettler`); the first change
/// also records the price it replaces from the first payment (`changePrice`). With no changes the history is
/// the price from the first payment, otherwise it is the changes.
nonisolated enum PriceHistory {
    struct Entry: Hashable, Sendable {
        let date: Date
        let price: Decimal
    }

    /// - Parameters:
    ///   - price: The subscription's price now.
    ///   - start: Its first payment.
    ///   - changes: Every price change, in any order.
    ///   - today: Changes after today are still to come and stay out.
    static func entries(price: Decimal, start: Date, changes: [(date: Date, price: Decimal)], through today: Date, calendar: Calendar) -> [Entry] {
        let end = calendar.startOfDay(for: today)
        let past = changes
            .map { Entry(date: calendar.startOfDay(for: $0.date), price: $0.price) }
            .filter { $0.date <= end }
            .sorted { $0.date > $1.date }
        return past.isEmpty ? [Entry(date: calendar.startOfDay(for: start), price: price)] : past
    }
}
