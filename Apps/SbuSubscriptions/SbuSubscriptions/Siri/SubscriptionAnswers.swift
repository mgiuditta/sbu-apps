import Foundation

/// What the intents answer, worked out from the subscriptions alone so it is tested without Siri.
enum SubscriptionAnswers {
    /// The ones you're paying: active and not paid off.
    static func count(_ subscriptions: [Subscription], today: Date = .now) -> Int {
        subscriptions.count { $0.nextPayment(after: today) != nil }
    }

    static func nextRenewal(_ subscriptions: [Subscription], of id: UUID? = nil, today: Date = .now) -> UpcomingPayment? {
        let chosen = id.map { id in subscriptions.filter { $0.uuid == id } } ?? subscriptions
        return UpcomingPayments.next(chosen, from: today, limit: 1).first
    }

    static func matching(_ text: String, in subscriptions: [Subscription]) -> [Subscription] {
        subscriptions.filter { $0.name.localizedStandardContains(text) }
    }
}
