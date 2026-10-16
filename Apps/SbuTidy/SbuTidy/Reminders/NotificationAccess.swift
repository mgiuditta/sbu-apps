/// What you said about Sbu Tidy's notifications.
nonisolated enum NotificationAccess: Equatable, Sendable {
    /// Not asked yet: the app asks when you turn reminders on.
    case notDetermined
    case allowed
    /// Refused, here or later in Impostazioni.
    case denied
}
