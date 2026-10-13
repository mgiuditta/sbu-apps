import Foundation

/// A backup that schedules nothing and is always allowed: previews, tests and UI tests (`SBU_NOISE_BACKUP=silent`).
final class SilentBackup: AlarmBackup {
    let kind: AlarmBackupKind
    var permission: AlarmBackupPermission
    private(set) var plans: [AlarmPlan] = []
    private(set) var cancelled: [UUID] = []

    init(kind: AlarmBackupKind = .notifications, permission: AlarmBackupPermission = .allowed) {
        self.kind = kind
        self.permission = permission
    }

    func requestPermission() async { permission = .allowed }
    func refreshPermission() async {}
    func replace(with plans: [AlarmPlan]) async { self.plans = plans }
    func cancel(alarmID: UUID) async {
        cancelled.append(alarmID)
        plans.removeAll { $0.alarmID == alarmID }
    }
}
