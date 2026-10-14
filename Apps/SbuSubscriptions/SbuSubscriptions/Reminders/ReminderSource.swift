import Foundation

/// What the plan needs to know about one subscription, copied out of the store.
nonisolated struct ReminderSource: Sendable {
    var id: String
    var name: String
    var price: Decimal
    var currencyCode: String
    var schedule: BillingSchedule
    var trialEnd: Date?
    /// Days before a payment; `nil` for no reminder.
    var daysBefore: Int?
    var isActive: Bool
}
