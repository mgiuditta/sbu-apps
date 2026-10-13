import Foundation

/// What rings when the app cannot: notifications up to iOS 25, a system alarm (AlarmKit) from
/// iOS 26. The app cancels it just before ringing the alarm itself, and when you stop it.
protocol AlarmBackup: AnyObject {
    var kind: AlarmBackupKind { get }
    /// Whether the user allowed it, as last read.
    var permission: AlarmBackupPermission { get }
    /// Asks once; afterwards only Impostazioni can change it.
    func requestPermission() async
    /// Reads the permission again, after a trip to Impostazioni.
    func refreshPermission() async
    /// Replaces everything scheduled with `plans`.
    func replace(with plans: [AlarmPlan]) async
    /// Takes back what is scheduled or showing for this alarm.
    func cancel(alarmID: UUID) async
}

/// One time the backup rings for an alarm.
nonisolated struct AlarmPlan: Equatable, Sendable {
    let alarmID: UUID
    let date: Date
}

nonisolated enum AlarmBackupKind: Sendable {
    case notifications
    case systemAlarm
}

nonisolated enum AlarmBackupPermission: Sendable {
    case notAsked
    case allowed
    case denied
}
