import Foundation

/// Numbers and days in a form every language reads back: a point for decimals, yyyy-MM-dd for days.
/// Reading is lenient, for files from spreadsheets: "12,50", "1.234,50", "€ 12.50", "31/12/2024".
nonisolated enum CSVValue {
    static func text(_ decimal: Decimal) -> String {
        "\(decimal)"
    }

    static func decimal(_ text: String) -> Decimal? {
        var digits = text.filter { $0.isNumber || $0 == "," || $0 == "." || $0 == "-" }
        guard digits.contains(where: \.isNumber) else { return nil }
        let lastComma = digits.lastIndex(of: ",")
        let lastPoint = digits.lastIndex(of: ".")
        switch (lastComma, lastPoint) {
        case let (comma?, point?):
            // The later mark is the decimal one, the other groups thousands.
            let decimalMark: Character = comma > point ? "," : "."
            digits = String(digits.compactMap { $0 == decimalMark ? "." : ($0 == "," || $0 == "." ? nil : $0) })
        case (_?, nil):
            // A single comma followed by three digits groups thousands in en_US ("1,234"); otherwise it is decimal.
            let parts = digits.split(separator: ",", omittingEmptySubsequences: false)
            digits = parts.count == 2 && parts[1].count != 3 ? parts.joined(separator: ".") : parts.joined()
        default:
            break
        }
        return Decimal(string: digits, locale: Locale(identifier: "en_US_POSIX"))
    }

    static func integer(_ text: String) -> Int? {
        decimal(text).map { NSDecimalNumber(decimal: $0).intValue }
    }

    /// yyyy-MM-dd in the calendar's time zone: a day, never an instant that could shift.
    static func day(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return padded(parts.year ?? 0, to: 4) + "-" + padded(parts.month ?? 0, to: 2) + "-" + padded(parts.day ?? 0, to: 2)
    }

    private static func padded(_ number: Int, to width: Int) -> String {
        let digits = String(number)
        return String(repeating: "0", count: max(width - digits.count, 0)) + digits
    }

    /// Reads yyyy-MM-dd, or dd/MM/yyyy and dd.MM.yyyy as Italian spreadsheets write them; noon of that day.
    static func date(_ text: String, calendar: Calendar) -> Date? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let numbers = trimmed.split(whereSeparator: { "-/.".contains($0) }).compactMap { Int($0) }
        guard numbers.count == 3 else { return nil }
        let (year, month, day) = numbers[0] > 31 ? (numbers[0], numbers[1], numbers[2]) : (numbers[2], numbers[1], numbers[0])
        guard (1...12).contains(month), (1...31).contains(day), year > 999 else { return nil }
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
    }
}
