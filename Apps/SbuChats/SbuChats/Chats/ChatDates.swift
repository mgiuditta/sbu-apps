import Foundation

/// How the app writes the dates of a chat.
enum ChatDates {
    /// "3 mar 2024", in the app's locale.
    /// No-break spaces inside, so a long line wraps between two dates, never inside one.
    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).year()).replacing(" ", with: "\u{00A0}")
    }

    /// "3 mar 2024 – 15 ott 2026", or one day when both fall on it.
    static func span(from start: Date, to end: Date) -> String {
        Calendar.current.isDate(start, inSameDayAs: end) ? day(start) : "\(day(start)) – \(day(end))"
    }
}
