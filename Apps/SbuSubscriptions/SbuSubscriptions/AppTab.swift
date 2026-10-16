/// The three tabs of the app (ADR-0012): the subscriptions with the figure, the payments calendar, settings.
nonisolated enum AppTab: Hashable, Sendable {
    case subscriptions
    case calendar
    case settings

    /// The tab a route from Siri, Shortcuts or Spotlight opens in.
    init(_ route: AppRoute) {
        switch route {
        case .calendar: self = .calendar
        case .subscription, .add: self = .subscriptions
        }
    }
}
