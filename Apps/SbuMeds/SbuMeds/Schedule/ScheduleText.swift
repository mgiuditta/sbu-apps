import Foundation

/// A schedule in words, for lists and the medicine's screen: "Ogni giorno alle 08:00 e 20:00".
nonisolated enum ScheduleText {
    static func frequencyName(_ frequency: Frequency) -> String {
        switch frequency {
        case .daily: String(localized: "Ogni giorno")
        case .weekdays: String(localized: "Giorni scelti")
        case .everyDays: String(localized: "Ogni N giorni")
        case .everyHours: String(localized: "Ogni N ore")
        case .cycle: String(localized: "A cicli")
        case .asNeeded: String(localized: "Al bisogno")
        }
    }

    /// When: "Ogni giorno", "lun, mer, ven", "Ogni 2 giorni", "Ogni 8 ore", "21 giorni sì, 7 no", "Al bisogno".
    static func days(of schedule: Schedule, calendar: Calendar) -> String {
        switch schedule.frequency {
        case .daily: return String(localized: "Ogni giorno")
        case .weekdays:
            let symbols = calendar.shortWeekdaySymbols
            // In the calendar's week order: Monday first in Italy.
            let ordered = (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }.filter(schedule.weekdays.contains)
            return ordered.map { symbols[$0 - 1] }.formatted(.list(type: .and, width: .narrow).locale(calendar.locale ?? .current))
        case .everyDays: return String(localized: "Ogni \(schedule.interval) giorni")
        case .everyHours: return String(localized: "Ogni \(schedule.interval) ore")
        case .cycle: return String(localized: "\(schedule.cycleOn) giorni sì, \(schedule.cycleOff) no")
        case .asNeeded: return String(localized: "Al bisogno")
        }
    }

    /// The times of the day, in the calendar's locale: "08:00 e 20:00".
    static func times(of schedule: Schedule, calendar: Calendar) -> String {
        let day = Day(year: 2026, month: 1, day: 1)
        let locale = calendar.locale ?? .current
        var style = Date.FormatStyle.dateTime.hour().minute().locale(locale)
        style.timeZone = calendar.timeZone
        return schedule.effectiveTimes
            .map { day.date(atMinutes: $0.minutes, in: calendar).formatted(style) }
            .formatted(.list(type: .and).locale(locale))
    }

    /// One line for a list: "Ogni giorno · 08:00 e 20:00", or "Al bisogno".
    static func summary(of schedule: Schedule, calendar: Calendar) -> String {
        let times = times(of: schedule, calendar: calendar)
        let days = days(of: schedule, calendar: calendar)
        return times.isEmpty ? days : "\(days) · \(times)"
    }
}
