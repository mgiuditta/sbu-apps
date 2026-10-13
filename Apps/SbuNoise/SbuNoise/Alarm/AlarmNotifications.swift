import UIKit
import UserNotifications

/// The alarm's notifications on the app side: the Rimanda and Ferma buttons, what a tap does, and
/// the silent notification that shows the ringing alarm on the lock screen. Created at launch, so
/// a tap that opens the app is never lost.
final class AlarmNotifications: NSObject, UNUserNotificationCenterDelegate {
    nonisolated static let snoozeAction = "alarm.snooze"
    nonisolated static let stopAction = "alarm.stop"

    private let alarms: AlarmsModel

    init(alarms: AlarmsModel) {
        self.alarms = alarms
        super.init()
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([
            UNNotificationCategory(
                identifier: NotificationBackup.categoryID,
                actions: [
                    UNNotificationAction(identifier: Self.snoozeAction, title: String(localized: "Rimanda"), options: []),
                    UNNotificationAction(identifier: Self.stopAction, title: String(localized: "Ferma"), options: [.destructive]),
                ],
                intentIdentifiers: []
            ),
        ])
        center.delegate = self
        alarms.didStartRinging = { [weak self] alarm in self?.showRinging(alarm) }
        alarms.didStopRinging = { alarm in
            center.removeDeliveredNotifications(withIdentifiers: [Self.ringingID(alarm)])
        }
    }

    /// With the app on screen and the alarm ringing full screen, the backup stays silent.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let isRinging = await MainActor.run { alarms.ringing != nil }
        return isRinging ? [] : [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let alarmID = NotificationBackup.alarmID(fromIdentifier: response.notification.request.identifier) else { return }
        let snooze = response.actionIdentifier == Self.snoozeAction
        await MainActor.run {
            alarms.handleBackupResponse(alarmID: alarmID, snooze: snooze)
        }
    }

    /// In the background the alarm is only heard: this puts it on the lock screen with its buttons,
    /// without a sound of its own.
    private func showRinging(_ alarm: SoundAlarm) {
        guard UIApplication.shared.applicationState != .active else { return }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Sveglia")
        content.body = String(localized: "Tocca per fermarla.")
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = NotificationBackup.categoryID
        let request = UNNotificationRequest(identifier: Self.ringingID(alarm), content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private static func ringingID(_ alarm: SoundAlarm) -> String {
        "\(NotificationBackup.prefix(alarm.id))ringing"
    }
}
