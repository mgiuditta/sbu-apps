import Foundation
import UserNotifications

/// Hands phase alerts to iOS. The only notifications the app ever sends, all local.
struct SystemPhaseAlertCenter: PhaseAlertCenter {
    func access() async -> NotificationAccess {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .notDetermined: .notDetermined
        case .denied: .denied
        default: .allowed
        }
    }

    func requestAccess() async -> NotificationAccess {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        return await access()
    }

    func replace(with alerts: [PlannedPhaseAlert]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let calendar = Calendar.current
        for alert in alerts {
            let content = UNMutableNotificationContent()
            content.title = alert.phase.localizedName
            let time = alert.eventDate.formatted(date: .omitted, time: .shortened)
            content.body = String(localized: "Oggi alle \(time).", comment: "Phase alert body: the phase happens today at this time.")
            content.sound = .default
            let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alert.fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            // An alert iOS refuses is skipped; the next time the app opens plans it again.
            center.add(UNNotificationRequest(identifier: alert.identifier, content: content, trigger: trigger))
        }
    }
}
