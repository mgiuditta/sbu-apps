import Foundation

/// How the home orders its rows.
nonisolated enum HomeSort: String, CaseIterable, Sendable {
    case nextPayment, name, monthlyPrice
}

/// How the home groups the subscriptions you pay: by state (trials, then active), by cycle, or by category.
nonisolated enum HomeGrouping: String, CaseIterable, Sendable {
    case status, cycle, category
}

/// Which subscriptions the home shows, and totals: one list, one category, one payment method, or all.
/// Empty means no filter. Names, not references, so the choice survives in `@AppStorage`.
nonisolated struct HomeFilter: Equatable, Sendable {
    var list = ""
    var category = ""
    var paymentMethod = ""

    var isActive: Bool { !list.isEmpty || !category.isEmpty || !paymentMethod.isEmpty }
}

extension HomeFilter {
    func matches(_ subscription: Subscription) -> Bool {
        (list.isEmpty || subscription.list?.name == list)
            && (category.isEmpty || subscription.category?.name == category)
            && (paymentMethod.isEmpty || subscription.paymentMethod == paymentMethod)
    }
}
