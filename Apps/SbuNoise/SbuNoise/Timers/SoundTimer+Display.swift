import Foundation

nonisolated extension SoundTimer {
    /// The countdown or the time of day, as the row shows it: "1 h 30 min", "23:30".
    func title(calendar: Calendar = .current) -> String {
        switch trigger {
        case .duration(let minutes):
            Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
        case .clock(let hour, let minute):
            (calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now)
                .formatted(.dateTime.hour().minute())
        }
    }

    /// "Mai", "Sempre", "Ogni giorno" or the weekdays, in the calendar's order.
    func repeatSummary(calendar: Calendar = .current) -> String {
        switch trigger {
        case .duration:
            return repeatsAlways ? String(localized: "Sempre") : String(localized: "Mai")
        case .clock:
            if weekdays.isEmpty { return String(localized: "Mai") }
            if weekdays.count == 7 { return String(localized: "Ogni giorno") }
            return Self.orderedWeekdays(calendar)
                .filter(weekdays.contains)
                .map { calendar.shortWeekdaySymbols[$0 - 1] }
                .formatted(.list(type: .and, width: .short))
        }
    }

    /// The `Calendar` weekdays starting from the locale's first day of the week.
    static func orderedWeekdays(_ calendar: Calendar = .current) -> [Int] {
        (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
    }
}
