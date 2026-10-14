import Foundation

/// The sum of some charges over a period, in the main currency. A charge whose currency has no rate is
/// left out and counted in `missingRates`, never added as if it were in the main currency.
nonisolated struct SpendingTotal: Hashable, Sendable {
    private(set) var amount: Decimal = 0
    /// Charges in the total.
    private(set) var count = 0
    /// Charges left out for lack of a rate, by currency code.
    private(set) var missingRates: [String: Int] = [:]
    /// Whether any charge was converted from another currency.
    private(set) var isConverted = false

    init(_ charges: [Charge], per period: TotalPeriod, in mainCurrency: String, converter: CurrencyConverter) {
        for charge in charges {
            guard let amount = charge.amount(per: period) else { continue }
            guard let converted = converter.convert(amount, from: charge.currencyCode, to: mainCurrency) else {
                missingRates[charge.currencyCode, default: 0] += 1
                continue
            }
            self.amount += converted
            count += 1
            isConverted = isConverted || charge.currencyCode != mainCurrency
        }
    }
}
