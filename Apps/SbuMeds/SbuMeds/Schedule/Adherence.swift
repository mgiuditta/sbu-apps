import Foundation

/// How many scheduled doses were taken in a period, as Medisafe's report counts them: doses still
/// to take today are not counted yet, extras never.
nonisolated struct Adherence: Hashable, Sendable {
    let taken: Int
    let skipped: Int
    let missed: Int

    init(taken: Int, skipped: Int, missed: Int) {
        self.taken = taken
        self.skipped = skipped
        self.missed = missed
    }

    /// The doses of `medicines` from `first` to `last`, both included, as they stand at `now`.
    init(_ medicines: [MedicineSnapshot], from first: Day, through last: Day, now: Date, calendar: Calendar) {
        var taken = 0, skipped = 0, missed = 0
        let today = Day(now, calendar: calendar)
        var day = first
        while day <= min(last, today) {
            for item in DayPlan(medicines, day: day, now: now, calendar: calendar).items where !item.isExtra {
                switch item.state {
                case .taken: taken += 1
                case .skipped: skipped += 1
                case .missed: missed += 1
                case .upcoming, .late: break
                }
            }
            day = day.adding(days: 1, in: calendar)
        }
        self.init(taken: taken, skipped: skipped, missed: missed)
    }

    /// Taken, skipped and missed: the doses whose time has come and gone, or were marked.
    var counted: Int { taken + skipped + missed }

    /// Taken over counted, 0 to 1; `nil` before any dose counts.
    var rate: Double? {
        counted == 0 ? nil : Double(taken) / Double(counted)
    }
}
