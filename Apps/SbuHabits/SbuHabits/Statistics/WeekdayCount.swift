/// Completions on one day of the week, for the Statistiche bars.
nonisolated struct WeekdayCount: Identifiable, Equatable, Sendable {
    /// Gregorian weekday, 1 for Sunday through 7 for Saturday.
    let weekday: Int
    let count: Int

    var id: Int { weekday }
}
