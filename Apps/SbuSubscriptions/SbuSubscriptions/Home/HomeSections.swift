import Foundation

/// The active subscriptions split into titled sections when grouped by cycle or category, keeping their order.
enum HomeSections {
    struct Group: Identifiable {
        let title: String
        let subscriptions: [Subscription]
        var id: String { title }
    }

    static func groups(_ active: [Subscription], by grouping: HomeGrouping) -> [Group] {
        let title: (Subscription) -> String = switch grouping {
        case .status: { _ in String(localized: "Attivi") }
        case .cycle: { cycleTitle($0.cycle) }
        case .category: { $0.category?.name ?? String(localized: "Senza categoria") }
        }
        var order: [String] = []
        var members: [String: [Subscription]] = [:]
        for subscription in active {
            let key = title(subscription)
            if members[key] == nil { order.append(key) }
            members[key, default: []].append(subscription)
        }
        if grouping != .status { order.sort { $0.localizedStandardCompare($1) == .orderedAscending } }
        return order.map { Group(title: $0, subscriptions: members[$0] ?? []) }
    }

    private static func cycleTitle(_ cycle: BillingCycle) -> String {
        switch cycle {
        case .once: String(localized: "Una tantum")
        case .every(1, .day): String(localized: "Ogni giorno")
        case .every(1, .week): String(localized: "Settimanale")
        case .every(1, .month): String(localized: "Mensile")
        case .every(1, .year): String(localized: "Annuale")
        case let .every(interval, .day): String(localized: "Ogni \(interval) giorni")
        case let .every(interval, .week): String(localized: "Ogni \(interval) settimane")
        case let .every(interval, .month): String(localized: "Ogni \(interval) mesi")
        case let .every(interval, .year): String(localized: "Ogni \(interval) anni")
        }
    }
}
