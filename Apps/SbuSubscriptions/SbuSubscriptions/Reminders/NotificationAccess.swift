/// What you said about Sbu Subscriptions' notifications.
nonisolated enum NotificationAccess: Equatable, Sendable {
    /// Not asked yet: the app asks once a subscription has a reminder.
    case notDetermined
    case allowed
    /// Refused, here or later in Impostazioni.
    case denied
}
