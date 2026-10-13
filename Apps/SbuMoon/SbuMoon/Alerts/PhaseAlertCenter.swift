import Foundation

/// Where phase alerts go: iOS's notification center in the app, a recorder in tests.
protocol PhaseAlertCenter {
    func access() async -> NotificationAccess
    /// Asks for permission; iOS shows its prompt only the first time.
    func requestAccess() async -> NotificationAccess
    /// Replaces every pending alert with `alerts`. Synchronous, so two quick changes never
    /// interleave and bring back an alert the newer plan dropped.
    func replace(with alerts: [PlannedPhaseAlert])
}
