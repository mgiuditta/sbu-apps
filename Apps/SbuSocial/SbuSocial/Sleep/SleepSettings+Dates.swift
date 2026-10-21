import Foundation

extension SleepSettings {
    /// Bedtime as today's date, for a time picker.
    var bedtimeDate: Date {
        get { Self.date(bedtime) }
        set { bedtime = Self.minutes(newValue) }
    }

    /// Waking as today's date, for a time picker.
    var wakeDate: Date {
        get { Self.date(wake) }
        set { wake = Self.minutes(newValue) }
    }

    private static func date(_ minutes: Int) -> Date {
        Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now
    }

    private static func minutes(_ date: Date) -> Int {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }
}
