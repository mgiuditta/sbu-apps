/// The time of an Orari automatici reminder: the hour the habit is usually done.
///
/// The rule: the first mark of each of the last `recentDays` days with an hour, and their
/// median hour, on the hour; a reminder at 18:00 for a habit done at 18:00–18:59 comes before
/// most of those times. Hours count from the start of the day, so 23:00 and 01:00 are two hours
/// apart, not twenty-two. With fewer than `minimumDays` days there is no habit to read yet, so it
/// reminds at `fallback`, in the evening: the time a "not done yet" reminder is still useful.
nonisolated enum AutomaticReminder {
    /// The time with too little history.
    static let fallback = ReminderTime(hour: 20, minute: 0)
    /// Days read: about two weeks, so a new routine wins within days.
    static let recentDays = 14
    /// Days needed before the hours say anything.
    static let minimumDays = 3

    /// - Parameters:
    ///   - markHours: The hour of each time marked, per logical day, as `Habit.markHours` keeps it.
    ///   - today: Days after it are ignored.
    ///   - startHour: The hour the logical day starts.
    static func time(from markHours: [LogicalDay: [Int]], through today: LogicalDay, startHour: Int) -> ReminderTime {
        let firstHours = markHours
            .filter { $0.key <= today && $0.value.isEmpty == false }
            .sorted { $0.key > $1.key }
            .prefix(recentDays)
            .compactMap(\.value.first)
        guard firstHours.count >= minimumDays else { return fallback }
        // Hours into the logical day, so the median never jumps across its start.
        let intoDay = firstHours.map { ($0 - startHour + 24) % 24 }.sorted()
        // The lower middle: with two candidates, the earlier one reminds in time for both.
        let median = intoDay[(intoDay.count - 1) / 2]
        return ReminderTime(hour: (median + startHour) % 24, minute: 0)
    }
}
