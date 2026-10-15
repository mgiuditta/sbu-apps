import Foundation

/// What a service cost and when, as the cost totals see it.
nonisolated struct ServiceCost: Equatable, Sendable {
    var date: Date
    var cost: Decimal
}
