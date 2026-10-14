import Foundation

/// The home sections: trials, active by next payment, then paused, cancelled and finished ones.
struct SubscriptionGroups {
    private(set) var trials: [Subscription] = []
    private(set) var active: [Subscription] = []
    private(set) var paused: [Subscription] = []
    private(set) var cancelled: [Subscription] = []
    private(set) var finished: [Subscription] = []
    /// The active ones that make up the recurring total.
    private(set) var counted: [Subscription] = []

    init(_ subscriptions: [Subscription], on date: Date, in calendar: Calendar = .current) {
        var dated: [(Subscription, Date)] = []
        for subscription in subscriptions {
            switch subscription.status {
            case .paused: paused.append(subscription)
            case .cancelled: cancelled.append(subscription)
            case .active:
                if subscription.isInTrial(on: date, in: calendar) {
                    trials.append(subscription)
                } else if let next = subscription.nextPayment(after: date, in: calendar) {
                    dated.append((subscription, next))
                } else {
                    finished.append(subscription)
                }
            }
            if subscription.countsInTotal(on: date, in: calendar) { counted.append(subscription) }
        }
        active = dated.sorted { ($0.1, $0.0.name) < ($1.1, $1.0.name) }.map(\.0)
        trials.sort { ($0.trialEndDate ?? .distantFuture) < ($1.trialEndDate ?? .distantFuture) }
        for keyPath in [\SubscriptionGroups.paused, \.cancelled, \.finished] {
            self[keyPath: keyPath].sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        }
    }
}
