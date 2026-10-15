import Foundation

/// Reads a number typed in a field, in the phone's language: "42,5" in Italian, "42.5" in English.
nonisolated enum NumberText {
    static func decimal(_ text: String, locale: Locale) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        // The decimal keypad of the other language types the other mark: accept it when there is only one.
        let separator = locale.decimalSeparator ?? "."
        let other = separator == "," ? "." : ","
        var normalised = trimmed
        if !trimmed.contains(separator), trimmed.components(separatedBy: other).count == 2,
           trimmed.components(separatedBy: other)[1].count != 3 {
            normalised = trimmed.replacingOccurrences(of: other, with: separator)
        }
        return try? Decimal(normalised, format: Decimal.FormatStyle(locale: locale))
    }

    static func double(_ text: String, locale: Locale) -> Double? {
        decimal(text, locale: locale).map { NSDecimalNumber(decimal: $0).doubleValue }
    }

    /// A number back into a field, without grouping so it reads back the same.
    static func text(_ value: Double, fractionDigits: ClosedRange<Int>, locale: Locale) -> String {
        value.formatted(.number.precision(.fractionLength(fractionDigits)).grouping(.never).locale(locale))
    }

    static func text(_ value: Decimal, locale: Locale) -> String {
        value.formatted(.number.precision(.fractionLength(0...3)).grouping(.never).locale(locale))
    }
}
