import ManagedSettings
import UserNotifications

/// The Shield's buttons. "Apri in Sbu Social" opens the app on iOS 26.5 and later; before, iOS
/// lets a Shield only close, so it leaves a notification to tap. "Chiudi" closes the app.
final class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action, completionHandler: completionHandler)
    }

    private func handle(_ action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        guard action == .primaryButtonPressed else {
            completionHandler(.close)
            return
        }
        if #available(iOS 26.5, *) {
            completionHandler(.openParentalControlsApp)
            return
        }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Apri Sbu Social")
        content.body = String(localized: "Tocca per aprire i social senza video brevi.")
        let request = UNNotificationRequest(identifier: "open-sbu-social", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { _ in
            completionHandler(.close)
        }
    }
}
