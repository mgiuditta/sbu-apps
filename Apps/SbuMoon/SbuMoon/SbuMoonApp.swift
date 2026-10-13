import SwiftUI
import UserNotifications

@main
struct SbuMoonApp: App {
    /// Kept for the app's lifetime: the notification center holds its delegate weakly.
    private let notificationPresenter = ForegroundNotificationPresenter()

    init() {
        UNUserNotificationCenter.current().delegate = notificationPresenter
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
