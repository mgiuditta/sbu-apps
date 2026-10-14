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
        case .cycle: { CycleText.text($0.cycle) }
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
}
