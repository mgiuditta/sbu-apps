/// The cycles the form offers, with "custom" for every N days, weeks, months or years.
nonisolated enum CycleChoice: Hashable, CaseIterable, Sendable {
    case weekly, monthly, quarterly, yearly, custom, once

    init(_ cycle: BillingCycle) {
        self = switch cycle {
        case .once: .once
        case .every(1, .week): .weekly
        case .every(1, .month): .monthly
        case .every(3, .month): .quarterly
        case .every(1, .year): .yearly
        case .every: .custom
        }
    }
}
