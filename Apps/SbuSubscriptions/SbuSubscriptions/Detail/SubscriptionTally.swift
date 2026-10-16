import Foundation

/// What a subscription has cost so far and how long you've had it, for the rows of its detail.
nonisolated struct SubscriptionTally: Equatable, Sendable {
    /// Every payment made up to today, or up to the day it was paused or cancelled, each at its price that day.
    let spent: Decimal
    /// How many payments that is.
    let paymentCount: Int
    /// The day you have it from: the first payment, or the day you added it if that comes first.
    let since: Date

    /// - Parameters:
    ///   - schedule: The subscription's payments.
    ///   - addedOn: The day you added it to the app.
    ///   - stoppedOn: The day it was last paused or cancelled, if it is now; no payment after it counts.
    ///   - today: The day the tally is for.
    ///   - price: What one payment costs on a day, after any price change.
    init(schedule: BillingSchedule, addedOn: Date, stoppedOn: Date? = nil, today: Date, calendar: Calendar,
         price: (Date) -> Decimal) {
        let end = min(stoppedOn ?? today, today)
        let dayAfterEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end)) ?? end
        let payments = schedule.payments(from: schedule.start, to: dayAfterEnd, in: calendar)
        spent = payments.reduce(0) { $0 + price($1) }
        paymentCount = payments.count
        since = calendar.startOfDay(for: min(schedule.start, addedOn))
    }

    /// The units "Abbonato da" shows: years and months after a year, months after a month, else days.
    func tenureFields(on today: Date, calendar: Calendar) -> Set<Date.ComponentsFormatStyle.Field> {
        let elapsed = calendar.dateComponents([.year, .month], from: since, to: calendar.startOfDay(for: today))
        if (elapsed.year ?? 0) > 0 { return (elapsed.month ?? 0) > 0 ? [.year, .month] : [.year] }
        if (elapsed.month ?? 0) > 0 { return [.month] }
        return [.day]
    }
}
