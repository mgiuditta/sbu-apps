import Foundation

/// Reads a number typed in a field, in the phone's language: "7,5" in Italian, "7.5" in English.
///
/// Strict: digits, an optional minus, and at most one decimal mark. Credits and averages never
/// need thousands, so "1.000" or "7,,5" is not a number here rather than a guess.
nonisolated enum NumberText {
    static func double(_ text: String, locale: Locale) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        // Either mark: the decimal keypad of the other language types the other one.
        guard trimmed.wholeMatch(of: /-?[0-9]+([.,][0-9]+)?/) != nil else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    /// A number back into a field, without grouping so it reads back the same.
    static func text(_ value: Double, fractionDigits: ClosedRange<Int>, locale: Locale) -> String {
        value.formatted(.number.precision(.fractionLength(fractionDigits)).grouping(.never).locale(locale))
    }
}
