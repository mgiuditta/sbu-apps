import CloudKit
import UIKit

/// What SwiftUI leaves to UIKit for the shared lists: the silent notification iCloud sends when one
/// changes, and the scene delegate that receives an accepted invitation.
final class AppDelegate: NSObject, UIApplicationDelegate {
    /// Set by the app at launch, before any notification or invitation can arrive.
    static var received: ReceivedLists?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Silent notifications only: no permission is asked, nothing is ever shown.
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        guard CKNotification(fromRemoteNotificationDictionary: userInfo) != nil, let received = Self.received else { return .noData }
        let before = received.lists
        await received.refresh()
        return received.lists == before ? .noData : .newData
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
