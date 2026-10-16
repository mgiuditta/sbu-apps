/// What you said about Sbu Meds's notifications.
nonisolated enum NotificationAccess: Equatable, Sendable {
    /// Not asked yet: the app asks when the first medicine with a time is saved.
    case notDetermined
    case allowed
    /// Refused, here or later in Impostazioni.
    case denied
}
