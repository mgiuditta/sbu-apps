/// A habit's goal, schedule and Limite as they were before an edit, so past days keep being judged by
/// the rules they were lived under.
nonisolated struct HabitSettings: Hashable, Codable, Sendable {
    /// The first day these settings no longer applied: the day of the edit.
    let until: LogicalDay
    let timesPerDay: Int
    let schedule: Schedule
    /// Missing in files saved before the Abitudine da evitare existed.
    var limit: Int? = nil
}
