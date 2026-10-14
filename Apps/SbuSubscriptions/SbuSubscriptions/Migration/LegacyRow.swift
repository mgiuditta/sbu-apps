/// One row of the 1.0's `subscriptions` table, as SQLite gives it back.
nonisolated struct LegacyRow: Sendable {
    var id: Int
    var name: String
    var amount: Double
    var currency: String
    var billingCycle: String
    var nextRenewalDate: String
    var category: String?
    var iconSlug: String?
    var isTrial: Bool
    var trialEndsAt: String?
    var reminderDaysBefore: Int
    var notes: String?
    var createdAt: String
}
