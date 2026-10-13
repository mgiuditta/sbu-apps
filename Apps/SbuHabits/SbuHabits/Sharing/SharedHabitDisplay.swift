import Foundation

/// How a received Abitudine condivisa shows on this iPhone: its ring and Serie as of the owner's
/// own day, since the owner's start of the day may differ from this user's, and the owner's icon.
nonisolated struct SharedHabitDisplay: Equatable, Sendable {
    let habit: Habit
    /// The owner's logical day now.
    let today: LogicalDay
    let progress: HabitProgress
    let streak: Int
    /// The emoji picked for the owner, `nil` for the person symbol.
    let ownerEmoji: String?

    init(_ received: ReceivedHabit, now: Date, calendar: Calendar = .current) {
        habit = received.habit
        today = received.today(at: now, calendar: calendar)
        progress = HabitProgress(of: habit, today: today, firstWeekday: calendar.firstWeekday)
        streak = Streak.current(of: habit, today: today, firstWeekday: calendar.firstWeekday)
        ownerEmoji = OwnerEmoji.validated(received.ownerEmoji)
    }

    var face: HabitRingFace {
        HabitRingFace(habit: habit, progress: progress)
    }
}
