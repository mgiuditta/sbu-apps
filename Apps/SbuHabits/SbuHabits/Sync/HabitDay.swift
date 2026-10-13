/// What happened to a habit on one logical day, as Sincronizza con iCloud merges it: the times
/// marked, their hours, and Salta oggi.
nonisolated struct HabitDay: Equatable, Sendable {
    var count = 0
    var hours: [Int] = []
    var isSkipped = false

    /// A skipped day: Salta oggi clears the marks, so a merged skip does too.
    static let skipped = HabitDay(isSkipped: true)

    init(count: Int = 0, hours: [Int] = [], isSkipped: Bool = false) {
        self.count = count
        self.hours = hours
        self.isSkipped = isSkipped
    }

    init(_ habit: Habit, on day: LogicalDay) {
        count = habit.count(on: day)
        hours = habit.markHours[day] ?? []
        isSkipped = habit.isSkipped(on: day)
    }

    /// The day as both copies agree on it.
    /// - Parameter base: The day as it was at the last sync, `nil` when there was none. A side
    ///   that still matches it did not change, so the other side's change wins, an undo too.
    /// When both changed: Salta oggi wins if either skipped; otherwise the higher count wins,
    /// with its own hours, never the sum.
    static func merge(_ local: HabitDay, _ remote: HabitDay, base: HabitDay?) -> HabitDay {
        if let base {
            if local == base { return remote }
            if remote == base { return local }
        }
        if local == remote { return local }
        if local.isSkipped || remote.isSkipped { return .skipped }
        if local.count != remote.count {
            return local.count > remote.count ? local : remote
        }
        // Same count, different hours: either is right, but both iPhones must pick the same.
        return local.hours.lexicographicallyPrecedes(remote.hours) ? remote : local
    }
}
