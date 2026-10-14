import Foundation
import SwiftData

/// Something that happened to a subscription, for its history.
@Model
final class SubscriptionEvent {
    nonisolated enum Kind: String, Codable, Sendable {
        case subscribed, paused, resumed, cancelled, reactivated, paid, priceChanged
    }

    var date: Date = Date.now
    var kind: Kind = Kind.subscribed
    /// The payment marked paid, or the new price.
    var amount: Decimal?
    var subscription: Subscription?

    init(_ kind: Kind, date: Date = .now, amount: Decimal? = nil) {
        self.kind = kind
        self.date = date
        self.amount = amount
    }
}
