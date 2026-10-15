import Foundation

/// How the app writes the dates of a chat.
enum ChatDates {
    /// "3 mar 2024", in the app's locale.
    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).year())
    }

    /// "3 mar 2024 – 15 ott 2026", or one day when both fall on it.
    static func span(from start: Date, to end: Date) -> String {
        Calendar.current.isDate(start, inSameDayAs: end) ? day(start) : "\(day(start)) – \(day(end))"
    }
}
