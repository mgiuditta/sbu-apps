/// The times habits were marked in each hour of the day, for the Statistiche curve.
nonisolated enum CompletionHours {
    /// Marks per hour on the clock, index 0 for 00:00–00:59 through 23, over the logical days in
    /// `period`. A mark at 01:00 that counts for the day before counts at hour 1, on that day.
    /// Days marked before hours were saved stay out; skipped days have no marks. Every mark of
    /// the habits given counts, so leave out an Abitudine da evitare to count only completions.
    static func counts(of habits: [Habit], in period: ClosedRange<LogicalDay>) -> [Int] {
        var counts = Array(repeating: 0, count: 24)
        for habit in habits {
            for (day, hours) in habit.markHours where period.contains(day) {
                for hour in hours where counts.indices.contains(hour) {
                    counts[hour] += 1
                }
            }
        }
        return counts
    }
}
