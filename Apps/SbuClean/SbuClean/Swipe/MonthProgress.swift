/// How far the user got through one month.
nonisolated struct MonthProgress: Identifiable, Hashable, Sendable {
    var month: YearMonth
    /// Items in the month, those kept forever included.
    var total: Int
    /// Items already decided: kept, in the bin, set aside or kept forever.
    var decided: Int

    var id: YearMonth { month }

    var isFinished: Bool {
        decided >= total
    }

    var fraction: Double {
        total == 0 ? 1 : Double(decided) / Double(total)
    }
}
