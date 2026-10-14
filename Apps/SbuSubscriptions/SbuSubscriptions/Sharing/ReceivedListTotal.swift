import Foundation

/// What a received list costs over a period, in your main currency, with your rates.
enum ReceivedListTotal {
    static func total(of snapshot: SharedListSnapshot, per period: TotalPeriod, in mainCurrency: String, converter: CurrencyConverter,
                      on date: Date, calendar: Calendar = .current) -> SpendingTotal {
        let charges = snapshot.items.filter { $0.countsInTotal(on: date, calendar: calendar) }
            .map { Charge(price: $0.price, currencyCode: $0.currencyCode, cycle: $0.cycle) }
        return SpendingTotal(charges, per: period, in: mainCurrency, converter: converter)
    }
}
