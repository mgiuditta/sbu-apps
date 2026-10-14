import Foundation

/// The payment dates of a subscription: from its start, one per cycle, for a fixed number of payments or until it stops.
///
/// Every payment is counted from the start, never from the previous payment, so a plan started on 31 January
/// pays on 28 (or 29) February and again on 31 March, and a yearly plan started on 29 February pays on 28 February
/// in the years in between.
nonisolated struct BillingSchedule: Hashable, Sendable {
    var start: Date
    var cycle: BillingCycle
    /// The number of payments for instalment plans; `nil` repeats until the subscription is cancelled.
    var paymentCount: Int?

    /// The payment with the given zero-based index, or `nil` past the last one.
    func payment(at index: Int, in calendar: Calendar) -> Date? {
        guard index >= 0, index < paymentCount ?? .max else { return nil }
        let first = calendar.startOfDay(for: start)
        switch cycle {
        case .once:
            return index == 0 ? first : nil
        case let .every(interval, unit):
            guard interval > 0 else { return index == 0 ? first : nil }
            return calendar.date(byAdding: unit.component, value: index * interval, to: first)
        }
    }

    /// The first payment on the day of `date` or later, or `nil` when the schedule has ended.
    func nextPayment(onOrAfter date: Date, in calendar: Calendar) -> Date? {
        let day = calendar.startOfDay(for: date)
        var index = firstIndexToCheck(before: day, in: calendar)
        while let payment = payment(at: index, in: calendar) {
            if payment >= day { return payment }
            index += 1
        }
        return nil
    }

    /// The payments on the days from `start` up to, not including, the day of `end`.
    func payments(from start: Date, to end: Date, in calendar: Calendar) -> [Date] {
        let last = calendar.startOfDay(for: end)
        var dates: [Date] = []
        var index = firstIndexToCheck(before: calendar.startOfDay(for: start), in: calendar)
        let first = calendar.startOfDay(for: start)
        while let payment = payment(at: index, in: calendar), payment < last {
            if payment >= first { dates.append(payment) }
            index += 1
        }
        return dates
    }

    /// Skips straight to the cycles near `day`, so a daily plan started years ago doesn't walk every day.
    private func firstIndexToCheck(before day: Date, in calendar: Calendar) -> Int {
        guard case let .every(interval, unit) = cycle, interval > 0 else { return 0 }
        let first = calendar.startOfDay(for: start)
        let elapsed = calendar.dateComponents([unit.component], from: first, to: day).value(for: unit.component) ?? 0
        return max(0, elapsed / interval - 1)
    }
}
