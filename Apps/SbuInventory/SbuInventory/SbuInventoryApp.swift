import SwiftData
import SwiftUI
import UserNotifications

@main
struct SbuInventoryApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer = {
        let defaults = UserDefaults.standard
        // Screenshots and UI tests run on a store of their own in memory, never on yours.
        if defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_SAMPLE_STORE"),
           let container = try? ModelContainer.inventory(inMemory: true) {
            InventorySample.insert(into: container.mainContext, wrapped: false)
            return container
        }
        if defaults.bool(forKey: "SBU_EMPTY_STORE"), let container = try? ModelContainer.inventory(inMemory: true) {
            return container
        }
        do {
            return try ModelContainer.inventory()
        } catch {
            fatalError("Inventory store failed to open: \(error)")
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
