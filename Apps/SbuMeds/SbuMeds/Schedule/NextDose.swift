import Foundation

/// The next dose of a medicine still to take: a late one today first, then the coming ones.
nonisolated enum NextDose {
    /// Days looked ahead: longer than any cycle pause.
    static let horizon = 2 * Schedule.maxCycleDays + 1

    static func of(_ medicine: MedicineSnapshot, now: Date, calendar: Calendar) -> DoseItem? {
        let today = Day(now, calendar: calendar)
        for offset in 0..<horizon {
            let day = today.adding(days: offset, in: calendar)
            guard medicine.schedule.isActive(on: day) else { return nil }
            let plan = DayPlan([medicine], day: day, now: now, calendar: calendar)
            if let item = plan.items.first(where: { !$0.isExtra && $0.state.isToTake }) {
                return item
            }
        }
        return nil
    }
}
