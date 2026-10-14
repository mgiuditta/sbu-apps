import Foundation
import SwiftData

/// One recurring payment you keep track of. Every property has a default so the store can sync through iCloud.
@Model
final class Subscription {
    var name: String = ""
    /// The catalog entry it was added from, if any.
    var serviceID: String?
    var price: Decimal = 0
    /// ISO 4217 code of `price`.
    var currencyCode: String = "EUR"
    /// The first payment; the schedule counts every later one from here.
    var startDate: Date = Date.now
    var cycle: BillingCycle = BillingCycle.monthly
    /// Instalment plans only; `nil` repeats until cancelled.
    var paymentCount: Int?
    var status: SubscriptionStatus = SubscriptionStatus.active
    /// The day the free trial turns into the first paid renewal.
    var trialEndDate: Date?
    /// Days before a payment to remind you; `nil` for no reminder.
    var reminderDaysBefore: Int? = 1
    var category: SubscriptionCategory?
    var list: SubscriptionList?
    /// A label such as "Carta personale"; never card details.
    var paymentMethod: String = ""
    var url: URL?
    var notes: String = ""
    var createdAt: Date = Date.now
    /// The row id in the 1.0's database, so importing it again never adds a copy.
    var legacyID: Int?

    init(
        name: String,
        price: Decimal,
        currencyCode: String,
        startDate: Date,
        cycle: BillingCycle = .monthly,
        paymentCount: Int? = nil
    ) {
        self.name = name
        self.price = price
        self.currencyCode = currencyCode
        self.startDate = startDate
        self.cycle = cycle
        self.paymentCount = paymentCount
    }

    var schedule: BillingSchedule {
        BillingSchedule(start: startDate, cycle: cycle, paymentCount: paymentCount)
    }

    /// The next payment you still have to make, or `nil` if it's paused, cancelled or paid off.
    func nextPayment(after date: Date = .now, in calendar: Calendar = .current) -> Date? {
        guard status == .active else { return nil }
        return schedule.nextPayment(onOrAfter: date, in: calendar)
    }

    func isInTrial(on date: Date = .now, in calendar: Calendar = .current) -> Bool {
        guard status == .active, let trialEndDate else { return false }
        return calendar.startOfDay(for: date) < calendar.startOfDay(for: trialEndDate)
    }
}

extension Subscription {
    var charge: Charge {
        Charge(price: price, currencyCode: currencyCode, cycle: cycle)
    }

    /// Whether it counts in the recurring total today: active, past its trial, and not paid off.
    func countsInTotal(on date: Date = .now, in calendar: Calendar = .current) -> Bool {
        !isInTrial(on: date, in: calendar) && nextPayment(after: date, in: calendar) != nil && cycle != .once
    }
}

extension Subscription {
    var reminderSource: ReminderSource {
        ReminderSource(id: "\(Int(createdAt.timeIntervalSince1970 * 1000))", name: name, price: price, currencyCode: currencyCode,
                       schedule: schedule, trialEnd: trialEndDate, daysBefore: reminderDaysBefore, isActive: status == .active)
    }
}
