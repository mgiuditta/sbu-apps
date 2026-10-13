import Foundation

/// Stops the sound at a time of day or after a duration, fading it out so it is silent right at
/// that moment. The sound only stops while the app is alive, that is while a sound plays.
nonisolated struct SoundTimer: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var isOn = true
    var fade = SoundTimerFade.thirtySeconds
    var trigger = SoundTimerTrigger.duration(minutes: 30)
    /// Duration timers only: armed again every time a sound starts, instead of turning off.
    var repeatsAlways = false
    /// Clock timers only: the `Calendar` weekdays (1 is Sunday) it repeats on; empty is once.
    var weekdays: Set<Int> = []
    /// Duration timers only: when the countdown started; `nil` until armed.
    var startedAt: Date?

    /// When the sound must be silent next, or `nil` if the timer is off or not armed.
    func fireDate(after now: Date, calendar: Calendar = .current) -> Date? {
        guard isOn else { return nil }
        switch trigger {
        case .duration(let minutes):
            return startedAt?.addingTimeInterval(TimeInterval(minutes * 60))
        case .clock(let hour, let minute):
            let days: [Int?] = weekdays.isEmpty ? [nil] : weekdays.map(Optional.some)
            return days.compactMap { weekday in
                calendar.nextDate(after: now, matching: DateComponents(hour: hour, minute: minute, weekday: weekday), matchingPolicy: .nextTime)
            }.min()
        }
    }

    /// When the fade starts for a timer that fires at `date`: never before `now`.
    func fadeStart(firingAt date: Date, now: Date) -> Date {
        max(now, date.addingTimeInterval(-fade.duration))
    }

    /// The timer after it fired: one-off timers turn off, repeating duration timers wait for the next sound.
    func fired() -> SoundTimer {
        var timer = self
        timer.startedAt = nil
        switch trigger {
        case .duration: timer.isOn = repeatsAlways
        case .clock: timer.isOn = !weekdays.isEmpty
        }
        return timer
    }

    /// The timer turned on or off at `now`: a duration starts counting when turned on.
    func turned(on: Bool, at now: Date) -> SoundTimer {
        var timer = self
        timer.isOn = on
        if case .duration = trigger { timer.startedAt = on ? now : nil }
        return timer
    }

    /// The timer that fires first among `timers`, with its date.
    static func next(in timers: [SoundTimer], after now: Date, calendar: Calendar = .current) -> (timer: SoundTimer, date: Date)? {
        timers
            .compactMap { timer in timer.fireDate(after: now, calendar: calendar).map { (timer, $0) } }
            .min { $0.1 < $1.1 }
    }
}
