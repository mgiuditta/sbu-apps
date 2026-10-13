import CloudKit
import UIKit

/// What SwiftUI leaves to UIKit for the Abitudini condivise: the silent notification iCloud sends
/// when a shared habit changes, and the scene delegate that receives an accepted invitation.
final class AppDelegate: NSObject, UIApplicationDelegate {
    /// Set by the app at launch, before any notification or invitation can arrive. Not reachable
    /// through `UIApplication.shared.delegate`, which SwiftUI keeps for itself.
    static var received: ReceivedHabits?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Silent notifications only: no permission is asked, nothing is ever shown.
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        guard CKNotification(fromRemoteNotificationDictionary: userInfo) != nil, let received = Self.received else { return .noData }
        let before = received.habits
        await received.refresh()
        return received.habits == before ? .noData : .newData
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
