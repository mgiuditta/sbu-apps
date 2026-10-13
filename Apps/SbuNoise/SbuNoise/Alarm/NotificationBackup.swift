import Foundation
import UserNotifications

/// The backup up to iOS 25: five Time Sensitive notifications, one a minute from the alarm's time,
/// with the Rintocchi under 30 seconds. At most 12 alarms × 5 fit in the 64 notifications iOS keeps.
final class NotificationBackup: AlarmBackup {
    static let categoryID = "alarm"
    static let repeats = 5

    let kind = AlarmBackupKind.notifications
    private(set) var permission = AlarmBackupPermission.notAsked
    private let center = UNUserNotificationCenter.current()

    func requestPermission() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
        await refreshPermission()
    }

    func refreshPermission() async {
        permission = switch await center.notificationSettings().authorizationStatus {
        case .notDetermined: .notAsked
        case .denied: .denied
        default: .allowed
        }
    }

    func replace(with plans: [AlarmPlan]) async {
        let pending = await center.pendingNotificationRequests().map(\.identifier).filter { $0.hasPrefix("alarm.") }
        center.removePendingNotificationRequests(withIdentifiers: pending)
        for plan in plans {
            for request in Self.requests(for: plan) {
                try? await center.add(request)
            }
        }
    }

    func cancel(alarmID: UUID) async {
        let prefix = Self.prefix(alarmID)
        let pending = await center.pendingNotificationRequests().map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: pending)
        let delivered = await center.deliveredNotifications().map(\.request.identifier).filter { $0.hasPrefix(prefix) }
        center.removeDeliveredNotifications(withIdentifiers: delivered)
    }

    /// "alarm.<alarm id>.": every notification of one alarm starts with it.
    nonisolated static func prefix(_ alarmID: UUID) -> String {
        "alarm.\(alarmID.uuidString)."
    }

    /// The alarm a notification belongs to, from its identifier.
    nonisolated static func alarmID(fromIdentifier identifier: String) -> UUID? {
        let parts = identifier.split(separator: ".")
        guard parts.count >= 2, parts[0] == "alarm" else { return nil }
        return UUID(uuidString: String(parts[1]))
    }

    private static func requests(for plan: AlarmPlan) -> [UNNotificationRequest] {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Sveglia")
        content.body = String(localized: "Sono le \(plan.date.formatted(.dateTime.hour().minute())). Tocca per fermarla.")
        content.sound = UNNotificationSound(named: UNNotificationSoundName(Sound.alarmNotificationSoundName))
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = categoryID
        content.threadIdentifier = plan.alarmID.uuidString
        let stamp = Int(plan.date.timeIntervalSince1970)
        return (0..<repeats).map { minute in
            let date = plan.date.addingTimeInterval(TimeInterval(minute * 60))
            let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            return UNNotificationRequest(identifier: "\(prefix(plan.alarmID))\(stamp).\(minute)", content: content, trigger: trigger)
        }
    }
}
