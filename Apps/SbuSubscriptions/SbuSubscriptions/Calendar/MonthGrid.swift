import Foundation

/// The days of a month laid out in weeks, starting on the locale's first weekday.
nonisolated struct MonthGrid: Sendable {
    /// Midnight of the 1st.
    let start: Date
    /// Midnight of the 1st of the next month.
    let end: Date
    /// `nil` for the blanks before the 1st, so the 1st sits under its weekday.
    let cells: [Date?]
    /// The very short weekday names in the order of the columns.
    let weekdaySymbols: [String]

    init(containing date: Date, calendar: Calendar) {
        let start = calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .month, value: 1, to: start) ?? start
        self.start = start
        self.end = end
        let blanks = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
        let days = calendar.range(of: .day, in: .month, for: start)?.count ?? 30
        cells = Array(repeating: nil, count: blanks) + (0..<days).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        weekdaySymbols = (0..<7).map { symbols[($0 + calendar.firstWeekday - 1) % 7] }
    }

    func adding(months: Int, calendar: Calendar) -> MonthGrid {
        MonthGrid(containing: calendar.date(byAdding: .month, value: months, to: start) ?? start, calendar: calendar)
    }
}
