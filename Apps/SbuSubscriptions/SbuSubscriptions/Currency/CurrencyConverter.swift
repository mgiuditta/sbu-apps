import Foundation

/// Converts amounts between currencies with your own rates first and the bundled ECB table otherwise.
/// It never adds amounts of different currencies without a rate: a currency it can't price gives `nil`.
nonisolated struct CurrencyConverter: Hashable, Sendable {
    var table: ExchangeRates
    /// Your rates, by the code of the currency they price.
    var ownRates: [String: OwnRate] = [:]

    func convert(_ amount: Decimal, from source: String, to target: String) -> Decimal? {
        if source == target { return amount }
        // Direct first, so a main currency the ECB doesn't list still works with rates you typed in it.
        if let own = ownRates[source], own.currencyCode == target { return amount * own.value }
        if let own = ownRates[target], own.currencyCode == source, own.value > 0 { return amount / own.value }
        guard let euros = euros(amount, in: source), let perEuro = perEuro(target) else { return nil }
        return euros * perEuro
    }

    private func euros(_ amount: Decimal, in code: String) -> Decimal? {
        if let own = ownRates[code], own.currencyCode != code {
            guard let rate = tableRate(own.currencyCode) else { return nil }
            return amount * own.value / rate
        }
        guard let rate = tableRate(code) else { return nil }
        return amount / rate
    }

    private func perEuro(_ code: String) -> Decimal? {
        guard let oneUnitInEuros = euros(1, in: code), oneUnitInEuros > 0 else { return nil }
        return 1 / oneUnitInEuros
    }

    // Own rates are priced in a table currency only, so a chain of own rates can't loop.
    private func tableRate(_ code: String) -> Decimal? {
        table.perEuro[code]
    }
}
