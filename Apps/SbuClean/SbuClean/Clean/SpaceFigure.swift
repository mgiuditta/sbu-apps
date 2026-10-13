import Foundation

/// A number of bytes as the one figure of a screen: the number and its unit apart.
///
/// The same text as every other size in the app ("18,8 MB", "1,26 GB"), so a figure and the row
/// that leads to it never round differently. Units are decimal, as in Settings → General →
/// iPhone Storage.
nonisolated struct SpaceFigure: Equatable, Sendable {
    /// The number, already formatted for the locale, such as "18,8".
    let number: String
    /// The unit, such as "MB".
    let unit: String

    init(bytes: Int64, locale: Locale = .current) {
        let text = bytes.sizeText(locale: locale)
        if let space = text.lastIndex(where: \.isWhitespace) {
            number = String(text[..<space])
            unit = String(text[text.index(after: space)...])
        } else {
            number = text
            unit = ""
        }
    }

    /// Passes the number through, for the components that take a value and a format.
    let format = VerbatimFormat()
}

/// A format that returns its text as it is.
nonisolated struct VerbatimFormat: FormatStyle {
    func format(_ value: String) -> String {
        value
    }
}
