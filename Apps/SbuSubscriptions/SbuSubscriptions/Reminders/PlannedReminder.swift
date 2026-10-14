import Foundation

/// One notification to hand to iOS: which payment, how much, and when to say so.
nonisolated struct PlannedReminder: Equatable, Sendable {
    nonisolated enum Kind: Equatable, Sendable {
        case renewal
        /// The free trial ends and the first paid renewal comes.
        case trialEnds
    }

    var kind: Kind
    var subscriptionID: String
    var name: String
    var price: Decimal
    var currencyCode: String
    /// The day of the payment.
    var paymentDate: Date
    var daysBefore: Int
    /// When the notification arrives: the chosen time, `daysBefore` days ahead of the payment.
    var fireDate: Date

    /// Stable for the same payment, so a new plan replaces rather than duplicates.
    var identifier: String {
        "subscription-\(subscriptionID)-\(Int(paymentDate.timeIntervalSince1970))"
    }
}
