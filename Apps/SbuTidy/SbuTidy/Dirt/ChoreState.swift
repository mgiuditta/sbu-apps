import Foundation

/// How dirty a chore is now: Tody's level, time since last done over the frequency, and the
/// days to its due day, negative when late.
///
/// Status counts calendar days, so a chore due at 18:00 is to do from the morning; urgency
/// compares `dirtiness`, so a weekly chore one day late comes before a monthly one.
nonisolated struct ChoreState: Equatable, Sendable {
    let status: ChoreStatus
    /// 0 just done, 1 on the due moment, above 1 when late. Never negative.
    let dirtiness: Double
    /// The due day counted from today: 0 today, negative when late.
    let daysUntilDue: Int
    /// When the chore is due, pauses included.
    let dueDate: Date

    init(frequency: Frequency, clock: ChoreClock, now: Date, calendar: Calendar) {
        let length = frequency.length(from: clock.lastDone, calendar: calendar)
        dirtiness = clock.elapsed(at: now) / length
        dueDate = frequency.dueDate(after: clock.lastDone, calendar: calendar).addingTimeInterval(clock.pausedTime(at: now))
        daysUntilDue = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: dueDate)).day ?? 0
        status = if clock.isPaused {
            .paused
        } else if daysUntilDue < 0 {
            .overdue
        } else if daysUntilDue == 0 {
            .due
        } else {
            .clean
        }
    }

    /// Dirtiness for a bar: 0 to 1, full once due.
    var level: Double { min(max(dirtiness, 0), 1) }
}
