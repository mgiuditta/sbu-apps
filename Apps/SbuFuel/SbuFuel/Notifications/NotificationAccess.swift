/// What you said about Sbu Fuel's notifications.
nonisolated enum NotificationAccess: Equatable, Sendable {
    /// Not asked yet: the app asks when you add the first reminder.
    case notDetermined
    case allowed
    /// Refused, here or later in Impostazioni.
    case denied
}
