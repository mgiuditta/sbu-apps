import Foundation

/// What the user said about Sbu Moon's notifications.
nonisolated enum NotificationAccess: Equatable, Sendable {
    /// Not asked yet: the app asks when the first alert is turned on.
    case notDetermined
    case allowed
    /// Refused, here or later in Impostazioni.
    case denied
}
