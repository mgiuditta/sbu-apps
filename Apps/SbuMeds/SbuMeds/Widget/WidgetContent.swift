import Foundation

/// What the widget shows at a moment: doses still to take today for everyone, and the next ones.
nonisolated struct WidgetContent: Equatable, Sendable {
    nonisolated struct Item: Equatable, Hashable, Sendable {
        let dueDate: Date
        let name: String
        let amount: String
        /// Empty with only one person: the widget does not repeat "Io".
        let personName: String
        let isLate: Bool
    }

    let toTakeCount: Int
    let lateCount: Int
    /// Doses due today, extras left out: with none, nothing is to take and nothing is done.
    let scheduledCount: Int
    /// Still to take today, the earliest first.
    let items: [Item]
    /// No medicine yet: the widget says how to start.
    let isEmpty: Bool

    init(_ medicines: [MedicineSnapshot], at now: Date, calendar: Calendar, limit: Int, locale: Locale = .current) {
        let plan = DayPlan(medicines, day: Day(now, calendar: calendar), now: now, calendar: calendar)
        let toTake = plan.items.filter { !$0.isExtra && $0.state.isToTake }
        let showsPerson = Set(medicines.map(\.personID)).count > 1
        toTakeCount = toTake.count
        scheduledCount = plan.scheduledCount
        lateCount = toTake.filter { $0.state == .late }.count
        isEmpty = medicines.isEmpty
        items = toTake.prefix(max(limit, 0)).map {
            Item(dueDate: $0.dueDate, name: $0.medicine.name, amount: $0.medicine.form.amountText($0.amount, locale: locale),
                 personName: showsPerson ? $0.medicine.personName : "", isLate: $0.state == .late)
        }
    }

    init(toTakeCount: Int, lateCount: Int, scheduledCount: Int? = nil, items: [Item], isEmpty: Bool) {
        self.toTakeCount = toTakeCount
        self.lateCount = lateCount
        self.scheduledCount = scheduledCount ?? toTakeCount
        self.items = items
        self.isEmpty = isEmpty
    }

    /// Every dose due today is taken, skipped or past: the full stop is set.
    var isDone: Bool { scheduledCount > 0 && toTakeCount == 0 }

    /// The moments the widget changes by itself: now, each dose time still to come today (it
    /// turns late), and the next midnights (a new day's doses).
    static func moments(for medicines: [MedicineSnapshot], from now: Date, calendar: Calendar, days: Int) -> [Date] {
        let today = Day(now, calendar: calendar)
        let doseTimes = DayPlan(medicines, day: today, now: now, calendar: calendar).items
            .filter { $0.state == .upcoming }
            .map(\.dueDate)
        let midnights = (1...max(days, 1)).map { today.adding(days: $0, in: calendar).start(in: calendar) }
        return Array(Set([now] + doseTimes + midnights)).sorted()
    }
}
