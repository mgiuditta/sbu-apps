import Foundation

/// What one subscription costs and how often, the input of a total.
nonisolated struct Charge: Hashable, Sendable {
    var price: Decimal
    var currencyCode: String
    var cycle: BillingCycle

    /// The cost over one period, in the charge's own currency; `nil` for a one-off payment, which recurs over no period.
    func amount(per period: TotalPeriod) -> Decimal? {
        guard case let .every(interval, unit) = cycle, interval > 0 else { return nil }
        let perYear: Decimal = switch unit {
        case .day: price * 365 / Decimal(interval)
        case .week: price * 52 / Decimal(interval)
        case .month: price * 12 / Decimal(interval)
        case .year: price / Decimal(interval)
        }
        return period == .year ? perYear : perYear / 12
    }
}
