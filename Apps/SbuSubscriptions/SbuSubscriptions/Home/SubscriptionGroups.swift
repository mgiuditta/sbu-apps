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

    var isEmpty: Bool {
        trials.isEmpty && active.isEmpty && paused.isEmpty && cancelled.isEmpty && finished.isEmpty
    }

    /// - Parameters:
    ///   - monthlyPrice: What a subscription costs a month in the main currency, for `.monthlyPrice`; `nil` sorts last.
    init(_ subscriptions: [Subscription], on date: Date, sort: HomeSort = .nextPayment, monthlyPrice: (Subscription) -> Decimal? = { _ in nil }, in calendar: Calendar = .current) {
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
        switch sort {
        case .nextPayment:
            active = dated.sorted { ($0.1, $0.0.name) < ($1.1, $1.0.name) }.map(\.0)
        case .name:
            active = dated.map(\.0).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .monthlyPrice:
            let prices = Dictionary(dated.map { ($0.0.persistentModelID, monthlyPrice($0.0)) }, uniquingKeysWith: { first, _ in first })
            active = dated.map(\.0).sorted { first, second in
                switch (prices[first.persistentModelID] ?? nil, prices[second.persistentModelID] ?? nil) {
                case let (a?, b?): a == b ? first.name < second.name : a > b
                case (.some, nil): true
                case (nil, .some): false
                case (nil, nil): first.name < second.name
                }
            }
        }
        trials.sort { ($0.trialEndDate ?? .distantFuture) < ($1.trialEndDate ?? .distantFuture) }
        for keyPath in [\SubscriptionGroups.paused, \.cancelled, \.finished] {
            self[keyPath: keyPath].sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        }
    }
}
