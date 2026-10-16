/// What the history records when a subscription goes from one state to another.
nonisolated enum StatusChange {
    /// The event for the change, or `nil` when the state stays the same.
    static func event(from old: SubscriptionStatus, to new: SubscriptionStatus) -> SubscriptionEvent.Kind? {
        switch (old, new) {
        case (.active, .active), (.paused, .paused), (.cancelled, .cancelled): nil
        case (_, .paused): .paused
        case (_, .cancelled): .cancelled
        case (.paused, .active): .resumed
        case (.cancelled, .active): .reactivated
        }
    }
}
