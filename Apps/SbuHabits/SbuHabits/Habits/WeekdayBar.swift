/// One bar of the weekday widget: a day of the week's completions, and its height as a share of
/// the tallest bar.
nonisolated struct WeekdayBar: Identifiable, Equatable, Sendable {
    /// Gregorian weekday, 1 for Sunday through 7 for Saturday.
    let weekday: Int
    let count: Int
    /// From 0 to 1: 1 for the day with the most completions, 0 for every day when none has any.
    let fraction: Double

    var id: Int { weekday }

    /// The bars in the order of `weekdays`, which starts from the first day of the user's week.
    static func bars(from weekdays: [WeekdayCount]) -> [WeekdayBar] {
        let highest = weekdays.map(\.count).max() ?? 0
        return weekdays.map { day in
            WeekdayBar(weekday: day.weekday, count: day.count, fraction: highest == 0 ? 0 : Double(day.count) / Double(highest))
        }
    }
}
