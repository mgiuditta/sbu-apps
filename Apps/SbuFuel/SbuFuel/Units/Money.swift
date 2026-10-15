import Foundation

/// Amounts in the phone's currency, as every entry records them.
nonisolated enum Money {
    static func currencyCode(for locale: Locale) -> String {
        locale.currency?.identifier ?? "EUR"
    }

    static func text(_ amount: Decimal, locale: Locale = .current) -> String {
        amount.formatted(.currency(code: currencyCode(for: locale)).locale(locale))
    }

    /// A price per unit with a tenth of a cent, as pumps show it: "1,789 €/L".
    static func perUnit(_ amount: Decimal, symbol: String, locale: Locale = .current) -> String {
        amount.formatted(.currency(code: currencyCode(for: locale)).precision(.fractionLength(3)).locale(locale)) + "/" + symbol
    }

    /// The fuel cost per kilometre or mile.
    static func perDistance(_ perKm: Decimal, unit: DistanceUnit, locale: Locale = .current) -> String {
        perUnit(perKm * Decimal(unit.km(from: 1)), symbol: unit.symbol, locale: locale)
    }

    /// The price per litre or gallon.
    static func perVolume(_ perLitre: Decimal, unit: VolumeUnit, locale: Locale = .current) -> String {
        perUnit(perLitre * Decimal(unit.litres(from: 1)), symbol: unit.symbol, locale: locale)
    }
}
