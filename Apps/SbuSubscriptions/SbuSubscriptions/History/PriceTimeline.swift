import Foundation

/// The price on a given day: the latest change that has started by then, else the base price.
nonisolated enum PriceTimeline {
    static func price(on day: Date, base: Decimal, changes: [(date: Date, price: Decimal)], calendar: Calendar) -> Decimal {
        let day = calendar.startOfDay(for: day)
        return changes
            .filter { calendar.startOfDay(for: $0.date) <= day }
            .max { $0.date < $1.date }?.price ?? base
    }
}
