/// What a one-habit widget shows under the habit's small ring, one per Streaks widget: the Serie
/// in large, the completion line, the bars per weekday, or the month's calendar.
nonisolated enum HabitInsight: String, CaseIterable, Sendable {
    case streak
    case rate
    case weekdays
    case calendar

    /// The line and the bars read the habit's Statistiche from its first day, as Streaks does.
    var needsStatistics: Bool {
        self == .rate || self == .weekdays
    }
}
