import Foundation

/// The payments a schedule has already made, newest first.
nonisolated enum PaymentHistory {
    static func past(_ schedule: BillingSchedule, through today: Date, limit: Int = 12, calendar: Calendar) -> [Date] {
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today)) else { return [] }
        // Every payment before tomorrow; when the schedule has ended, all of them.
        let count = schedule.nextPaymentIndex(onOrAfter: tomorrow, in: calendar) ?? schedule.paymentCount ?? (schedule.cycle == .once ? 1 : 0)
        return (max(0, count - limit)..<count).reversed().compactMap { schedule.payment(at: $0, in: calendar) }
    }
}
