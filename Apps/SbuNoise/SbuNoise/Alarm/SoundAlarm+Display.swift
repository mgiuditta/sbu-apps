import Foundation

nonisolated extension SoundAlarm {
    /// The time of day as the row shows it: "7:00".
    func title(calendar: Calendar = .current) -> String {
        (calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now)
            .formatted(date: .omitted, time: .shortened)
    }

    /// "Mai", "Ogni giorno" or the weekdays, as for a clock timer.
    func repeatSummary(calendar: Calendar = .current) -> String {
        SoundTimer(trigger: .clock(hour: hour, minute: minute), weekdays: weekdays).repeatSummary(calendar: calendar)
    }

    /// "9 minuti".
    static func snoozeLabel(_ minutes: Int) -> String {
        Duration.seconds(minutes * 60).formatted(.units(allowed: [.minutes], width: .wide))
    }
}
