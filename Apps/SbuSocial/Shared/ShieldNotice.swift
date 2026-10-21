import Foundation
import UserNotifications

/// The local notifications the Screen Time parts send.
nonisolated enum ShieldNotice {
    static func post(id: String, title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        try? await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: nil))
    }
}
