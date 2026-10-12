/// A time of day for a habit's reminder, in the user's time zone.
nonisolated struct ReminderTime: Hashable, Comparable, Codable, Sendable {
    let hour: Int
    let minute: Int

    static func < (lhs: ReminderTime, rhs: ReminderTime) -> Bool {
        (lhs.hour, lhs.minute) < (rhs.hour, rhs.minute)
    }
}
