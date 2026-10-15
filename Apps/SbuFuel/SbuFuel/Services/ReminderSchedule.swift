import Foundation

/// Works out when a reminder is due and how close it is.
nonisolated enum ReminderSchedule {
    /// A service within this many days is "soon".
    static let soonDays = 30
    /// A service within this many kilometres is "soon".
    static let soonKm = 1_000.0

    static func due(_ rule: ReminderRule, estimate: OdometerEstimate?, now: Date, calendar: Calendar) -> ReminderDue {
        let dueKm = rule.dueKm
        let dueDate = rule.dueDate(calendar: calendar)
        let remainingKm = dueKm.map { $0 - (estimate?.lastKm ?? rule.lastDoneOdometerKm ?? 0) }
        let estimated = dueKm.flatMap { estimate?.date(reaching: $0) }
        let today = calendar.startOfDay(for: now)
        let soonDay = calendar.date(byAdding: .day, value: soonDays, to: today) ?? today

        let status: ReminderStatus
        if let remainingKm, remainingKm <= 0 {
            status = .overdue
        } else if let dueDate, dueDate <= today {
            status = .overdue
        } else if let remainingKm, remainingKm <= soonKm {
            status = .soon
        } else if let first = [dueDate, estimated].compactMap({ $0 }).min(), first <= soonDay {
            status = .soon
        } else {
            status = .later
        }
        return ReminderDue(dueKm: dueKm, dueDate: dueDate, remainingKm: remainingKm, estimatedDateForKm: estimated, status: status)
    }
}
