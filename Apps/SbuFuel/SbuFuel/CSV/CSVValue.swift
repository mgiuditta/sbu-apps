import Foundation

/// Lenient readers for the cells of a file that may come from any spreadsheet or service.
nonisolated enum CSVValue {
    /// A number with either decimal mark, with or without grouping, currency symbols or units:
    /// "1.234,56 €", "1,234.56", "42,5", "$3.199". With `isReading`, for odometers, a single mark
    /// followed by exactly three digits groups thousands: "45.210" is 45210, never 45.21.
    static func decimal(_ text: String, isReading: Bool = false) -> Decimal? {
        var cleaned = text.filter { $0.isNumber || $0 == "," || $0 == "." || $0 == "-" }
        guard cleaned.contains(where: \.isNumber) else { return nil }
        if isReading, let mark = cleaned.lastIndex(where: { $0 == "," || $0 == "." }),
           cleaned.filter({ $0 == "," || $0 == "." }).count == 1,
           cleaned.distance(from: mark, to: cleaned.endIndex) == 4 {
            cleaned.remove(at: mark)
        }
        let lastComma = cleaned.lastIndex(of: ",")
        let lastDot = cleaned.lastIndex(of: ".")
        switch (lastComma, lastDot) {
        case let (comma?, dot?):
            // Both marks: the last one is the decimal mark, the other groups thousands.
            let decimalMark: Character = comma > dot ? "," : "."
            cleaned = cleaned.filter { $0 != (decimalMark == "," ? "." : ",") }
            cleaned = cleaned.replacingOccurrences(of: String(decimalMark), with: ".")
        case (_?, nil):
            // Commas only: more than one groups thousands, one is the decimal mark.
            cleaned = cleaned.filter { $0 == "," }.count > 1 ? cleaned.replacingOccurrences(of: ",", with: "") : cleaned.replacingOccurrences(of: ",", with: ".")
        case (nil, _?):
            // Dots only: several dots group thousands ("1.234.567"), one dot is the decimal mark.
            if cleaned.filter({ $0 == "." }).count > 1 { cleaned = cleaned.replacingOccurrences(of: ".", with: "") }
        case (nil, nil):
            break
        }
        return Decimal(string: cleaned, locale: Locale(identifier: "en_US_POSIX"))
    }

    static func double(_ text: String, isReading: Bool = false) -> Double? {
        decimal(text, isReading: isReading).map { NSDecimalNumber(decimal: $0).doubleValue }
    }

    /// Yes in the languages and spreadsheets people use: "si", "sì", "yes", "true", "1", "x".
    static func flag(_ text: String) -> Bool {
        ["si", "sì", "s", "yes", "y", "true", "vero", "1", "x"].contains(text.trimmingCharacters(in: .whitespaces).lowercased())
    }
}
