import Foundation

/// Which reminders to keep with iOS: the nearest ones first, never more than iOS holds.
nonisolated enum ReminderPlan {
    /// iOS keeps at most 64 pending notifications per app and drops the rest.
    static let limit = 64
    /// Payments looked at per subscription; the plan is made again every time the app opens.
    static let paymentsPerSubscription = 12

    static func reminders(
        for sources: [ReminderSource],
        hour: Int,
        minute: Int,
        after now: Date,
        calendar: Calendar,
        limit: Int = limit
    ) -> [PlannedReminder] {
        var planned: [PlannedReminder] = []
        for source in sources where source.isActive {
            guard let daysBefore = source.daysBefore else { continue }
            func reminder(_ kind: PlannedReminder.Kind, on payment: Date) -> PlannedReminder? {
                guard let day = calendar.date(byAdding: .day, value: -daysBefore, to: calendar.startOfDay(for: payment)),
                      let fire = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day),
                      fire > now else { return nil }
                let price = PriceTimeline.price(on: payment, base: source.price, changes: source.priceChanges, calendar: calendar)
                return PlannedReminder(kind: kind, subscriptionID: source.id, name: source.name, price: price,
                                       currencyCode: source.currencyCode, paymentDate: calendar.startOfDay(for: payment),
                                       daysBefore: daysBefore, fireDate: fire)
            }
            let trialEnd = source.trialEnd.map(calendar.startOfDay(for:))
            if let trialEnd, let trial = reminder(.trialEnds, on: trialEnd) {
                planned.append(trial)
            }
            guard var index = source.schedule.nextPaymentIndex(onOrAfter: now, in: calendar) else { continue }
            for _ in 0..<paymentsPerSubscription {
                guard let payment = source.schedule.payment(at: index, in: calendar) else { break }
                index += 1
                // The trial reminder already speaks for the payment the trial ends on.
                if payment == trialEnd { continue }
                if let renewal = reminder(.renewal, on: payment) { planned.append(renewal) }
            }
        }
        return Array(planned.sorted { $0.fireDate < $1.fireDate }.prefix(limit))
    }
}
