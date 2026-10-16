import Foundation

/// Formats a grid count as columns × rows, each number in the locale's digits: "4 × 6".
nonisolated struct GridCountFormatStyle: FormatStyle {
    var locale: Locale

    init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }

    func format(_ value: GridCount) -> String {
        let number = IntegerFormatStyle<Int>(locale: locale)
        return "\(number.format(value.columns)) × \(number.format(value.rows))"
    }

    func locale(_ locale: Locale) -> GridCountFormatStyle {
        GridCountFormatStyle(locale: locale)
    }
}

extension FormatStyle where Self == GridCountFormatStyle {
    /// Columns × rows: "4 × 6".
    static var gridCount: GridCountFormatStyle { GridCountFormatStyle() }
}
