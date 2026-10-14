/// Whether a subscription is still being paid. A free trial and a finished instalment plan follow from the dates.
nonisolated enum SubscriptionStatus: String, Codable, CaseIterable, Hashable, Sendable {
    case active
    case paused
    case cancelled
}
