import Foundation

extension WidgetSnapshot {
    /// When the widget redraws: now, then each of the next `days` midnights, so the countdown moves on its own.
    nonisolated static func entryDates(from now: Date, days: Int, calendar: Calendar) -> [Date] {
        let today = calendar.startOfDay(for: now)
        return [now] + (1...max(days, 1)).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }
}
