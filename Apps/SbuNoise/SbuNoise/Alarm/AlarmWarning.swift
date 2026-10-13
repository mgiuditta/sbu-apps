import Foundation

/// The cases in which an alarm is not as sure as it looks, said under the alarm with a symbol and
/// a word, as decided for Sbu Noise (#407).
nonisolated enum AlarmWarning: Hashable, Sendable {
    /// Notifications are off: if the app is not alive, nothing rings.
    case notificationsDenied
    /// System alarms are off (iOS 26): if the app is not alive, nothing rings.
    case systemAlarmsDenied
    /// A timer stops the sound before the alarm: only the backup will ring.
    case soundStopsBefore(AlarmBackupKind)

    /// The warnings for an alarm ringing at `alarmDate`.
    static func list(permission: AlarmBackupPermission, kind: AlarmBackupKind, alarmDate: Date?, timerStop: Date?) -> [AlarmWarning] {
        var warnings: [AlarmWarning] = []
        if permission == .denied {
            warnings.append(kind == .notifications ? .notificationsDenied : .systemAlarmsDenied)
        }
        if let alarmDate, let timerStop, timerStop < alarmDate {
            warnings.append(.soundStopsBefore(kind))
        }
        return warnings
    }

    var message: LocalizedStringResource {
        switch self {
        case .notificationsDenied:
            "Le notifiche di Sbu Noise sono spente: se l'app non è aperta, la sveglia non suona."
        case .systemAlarmsDenied:
            "Le sveglie di Sbu Noise sono spente: se l'app non è aperta, la sveglia non suona."
        case .soundStopsBefore(.notifications):
            "Il suono si ferma prima: la sveglia arriva solo come notifica."
        case .soundStopsBefore(.systemAlarm):
            "Il suono si ferma prima: la sveglia arriva solo come sveglia di sistema, senza dissolvenza."
        }
    }
}

nonisolated extension AlarmBackupKind {
    /// The fixed line under the alarms: when it rings in the app, and what happens otherwise.
    var footer: LocalizedStringResource {
        switch self {
        case .notifications:
            "La sveglia suona se Noise resta aperta con un suono attivo. Altrimenti arriva una notifica."
        case .systemAlarm:
            "La sveglia suona se Noise resta aperta con un suono attivo. Altrimenti suona una sveglia di sistema."
        }
    }
}
