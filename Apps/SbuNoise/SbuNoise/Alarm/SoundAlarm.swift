import Foundation

/// Wakes you at a time of day with a sound that fades in, as in the original. It rings inside the
/// app while a sound for sleeping keeps the app alive; otherwise the backup (notifications, or a
/// system alarm from iOS 26) rings instead.
nonisolated struct SoundAlarm: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var isOn = true
    var hour = 7
    var minute = 0
    /// The `Calendar` weekdays (1 is Sunday) it repeats on; empty is once.
    var weekdays: Set<Int> = []
    /// A sound of the catalog or an alarm tone (`Sound.alarmTones`).
    var soundID = Sound.alarmTones[0].id
    var fadeIn = AlarmFadeIn.oneMinute
    /// Minutes, one of `snoozeChoices`.
    var snoozeMinutes = 9
    /// A one-off alarm rings at the first matching time after this moment.
    var armedAt = Date.now
    /// After Rimanda: when it rings again.
    var snoozedUntil: Date?

    static let snoozeChoices = [5, 9, 10, 15, 20]

    /// When it rings next, or `nil` if it is off or a one-off time already passed.
    func fireDate(after now: Date, calendar: Calendar = .current) -> Date? {
        guard isOn else { return nil }
        let snooze = snoozedUntil.flatMap { $0 > now ? $0 : nil }
        let regular: Date?
        if weekdays.isEmpty {
            regular = calendar.nextDate(after: armedAt, matching: time, matchingPolicy: .nextTime).flatMap { $0 > now ? $0 : nil }
        } else {
            regular = weekdays.compactMap { weekday in
                var components = time
                components.weekday = weekday
                return calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)
            }.min()
        }
        return [snooze, regular].compactMap(\.self).min()
    }

    /// Turned on or saved at `now`: a one-off alarm rings at the next matching time.
    func armed(at now: Date) -> SoundAlarm {
        var alarm = self
        alarm.isOn = true
        alarm.armedAt = now
        alarm.snoozedUntil = nil
        return alarm
    }

    /// Rimanda: rings again `snoozeMinutes` after `now`.
    func snoozed(at now: Date) -> SoundAlarm {
        var alarm = self
        alarm.snoozedUntil = now.addingTimeInterval(TimeInterval(snoozeMinutes * 60))
        return alarm
    }

    /// Ferma: a one-off alarm turns off, a repeating one waits for its next day.
    func stopped(at now: Date) -> SoundAlarm {
        var alarm = self
        alarm.snoozedUntil = nil
        alarm.armedAt = now
        alarm.isOn = !weekdays.isEmpty
        return alarm
    }

    /// A one-off alarm whose time passed without the app ringing it (the backup did).
    func hasExpired(at now: Date) -> Bool {
        isOn && weekdays.isEmpty && fireDate(after: now) == nil
    }

    /// The alarm that rings first among `alarms`, with its date.
    static func next(in alarms: [SoundAlarm], after now: Date, calendar: Calendar = .current) -> (alarm: SoundAlarm, date: Date)? {
        alarms
            .compactMap { alarm in alarm.fireDate(after: now, calendar: calendar).map { (alarm, $0) } }
            .min { $0.1 < $1.1 }
    }

    private var time: DateComponents {
        DateComponents(hour: hour, minute: minute, second: 0)
    }
}
