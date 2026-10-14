/// How often a subscription is paid: once, or every N days, weeks, months or years.
nonisolated enum BillingCycle: Codable, Hashable, Sendable {
    case once
    case every(Int, BillingUnit)

    static let weekly = BillingCycle.every(1, .week)
    static let monthly = BillingCycle.every(1, .month)
    static let yearly = BillingCycle.every(1, .year)
}
