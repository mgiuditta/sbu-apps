import Foundation
import SwiftData

/// A new price from a given day on: a rise announced for next month stays out of the totals until then.
@Model
final class PriceChange {
    var effectiveDate: Date = Date.now
    var price: Decimal = 0
    var subscription: Subscription?

    init(effectiveDate: Date, price: Decimal) {
        self.effectiveDate = effectiveDate
        self.price = price
    }
}
