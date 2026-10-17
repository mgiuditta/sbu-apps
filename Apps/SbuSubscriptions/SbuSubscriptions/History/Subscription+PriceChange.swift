import Foundation
import SwiftData

extension Subscription {
    /// A new price from `day`. The first change also keeps the price it replaces, from the first payment:
    /// settling overwrites `price`, and without it every past payment would count at the new price.
    func changePrice(to newPrice: Decimal, from day: Date, in context: ModelContext, today: Date = .now, calendar: Calendar = .current) {
        let start = calendar.startOfDay(for: startDate)
        let effective = calendar.startOfDay(for: day)
        if (priceChanges ?? []).isEmpty, effective > start {
            add(PriceChange(effectiveDate: start, price: price), in: context)
        }
        add(PriceChange(effectiveDate: effective, price: newPrice), in: context)
        record(.priceChanged, amount: newPrice)
        // As PriceSettler does: a change that has started is the price now.
        let current = price(on: calendar.startOfDay(for: today), calendar: calendar)
        if current != price { price = current }
    }

    private func add(_ change: PriceChange, in context: ModelContext) {
        context.insert(change)
        change.subscription = self
    }
}
