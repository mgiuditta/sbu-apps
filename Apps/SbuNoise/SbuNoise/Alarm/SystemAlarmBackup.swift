import AlarmKit
import SbuKit
import SwiftUI

/// The backup from iOS 26: a system alarm (AlarmKit) at the alarm's time, which rings through
/// silent mode and Focus even if the app was closed. Only a Ferma button: Rimanda needs a
/// countdown, which needs a Live Activity. The app cancels it two seconds before ringing itself.
@available(iOS 26, *)
final class SystemAlarmBackup: AlarmBackup {
    let kind = AlarmBackupKind.systemAlarm
    private(set) var permission = AlarmBackupPermission.notAsked
    private let manager = AlarmManager.shared
    /// Which system alarm stands for which of ours: one per plan.
    private var scheduled: [UUID: UUID] = [:]

    init() {
        Task { await refreshPermission() }
    }

    func requestPermission() async {
        _ = try? await Self.requestAuthorization()
        await refreshPermission()
    }

    func refreshPermission() async {
        permission = switch manager.authorizationState {
        case .notDetermined: .notAsked
        case .denied: .denied
        case .authorized: .allowed
        @unknown default: .denied
        }
    }

    func replace(with plans: [AlarmPlan]) async {
        // Ours are the only system alarms of this app: after a relaunch the map is empty.
        for alarm in (try? manager.alarms) ?? [] {
            try? manager.cancel(id: alarm.id)
        }
        scheduled = [:]
        guard permission == .allowed else { return }
        for plan in plans {
            let id = UUID()
            if (try? await Self.schedule(id: id, plan: plan, buttonText: SbuTheme.onAccent, tint: SbuTheme.accentNoise)) != nil {
                scheduled[id] = plan.alarmID
            }
        }
    }

    func cancel(alarmID: UUID) async {
        for (id, owner) in scheduled where owner == alarmID {
            try? manager.cancel(id: id)
            scheduled[id] = nil
        }
    }

    // The manager is not Sendable: its async calls are made away from the main actor, on the
    // shared instance, with only Sendable values crossing over.

    private nonisolated static func requestAuthorization() async throws -> AlarmManager.AuthorizationState {
        try await AlarmManager.shared.requestAuthorization()
    }

    private nonisolated static func schedule(id: UUID, plan: AlarmPlan, buttonText: Color, tint: Color) async throws {
        let configuration = AlarmManager.AlarmConfiguration<NoiseAlarmMetadata>.alarm(
            schedule: .fixed(plan.date),
            attributes: AlarmAttributes(
                presentation: AlarmPresentation(alert: .init(
                    title: "Sveglia",
                    stopButton: AlarmButton(text: "Ferma", textColor: buttonText, systemImageName: "stop.fill")
                )),
                metadata: NoiseAlarmMetadata(alarmID: plan.alarmID),
                tintColor: tint
            ),
            sound: .named(Sound.alarmNotificationSoundName)
        )
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
    }
}
