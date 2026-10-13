import Foundation

/// An Abitudine condivisa someone else shares with this iPhone's user: read only, kept apart from
/// the user's own habits, with the icon the user picked for its owner.
nonisolated struct ReceivedHabit: Identifiable, Codable, Equatable, Hashable, Sendable {
    /// Where the share lives in iCloud, as `SharedHabitsInbox` names it.
    let key: String
    var snapshot: SharedHabitSnapshot
    /// The emoji the user picked for the owner, `nil` for the person symbol.
    var ownerEmoji: String?

    var id: String { key }
    var habit: Habit { snapshot.habit }

    /// The owner's logical day at `date`, the one its ring and Serie count.
    func today(at date: Date, calendar: Calendar = .current) -> LogicalDay {
        LogicalDay(date, startHour: snapshot.startHour, calendar: calendar)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(ownerEmoji)
    }
}
