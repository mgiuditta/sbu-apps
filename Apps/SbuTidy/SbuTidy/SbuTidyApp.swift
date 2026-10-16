import SwiftData
import SwiftUI
import UserNotifications

@main
struct SbuTidyApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer = {
        // fastlane snapshot shows the made-up home, never the user's own.
        if Launch.isSnapshot { return .preview }
        // UI flow tests start from an empty store of their own.
        if Launch.isEmptyStore, let container = try? ModelContainer.tidy(inMemory: true) { return container }
        do {
            return try ModelContainer.tidy()
        } catch {
            fatalError("Tidy store failed to open: \(error)")
        }
    }()

    private let notificationPresenter = ForegroundNotificationPresenter()

    init() {
        UNUserNotificationCenter.current().delegate = notificationPresenter
        Launch.resetDemoPreferences()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
