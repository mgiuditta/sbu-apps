import SwiftData
import SwiftUI
import UserNotifications

@main
struct SbuSubscriptionsApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer = {
        // fastlane snapshot shows made-up subscriptions, never the user's own.
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") { return .preview }
        // UI flow tests start from an empty store of their own, never the user's.
        if UserDefaults.standard.bool(forKey: "SBU_EMPTY_STORE"), let container = try? ModelContainer.subscriptions(inMemory: true) {
            try? CategorySeeder.seed(container.mainContext)
            return container
        }
        do {
            let container = try ModelContainer.subscriptions()
            try CategorySeeder.seed(container.mainContext)
            // Before the first screen: whoever updates from the 1.0 finds their subscriptions there.
            LegacyMigration.runIfNeeded(container.mainContext, currency: CurrencySettings())
            return container
        } catch {
            fatalError("Subscriptions store failed to open: \(error)")
        }
    }()

    private let notificationPresenter = ForegroundNotificationPresenter()

    init() {
        UNUserNotificationCenter.current().delegate = notificationPresenter
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
