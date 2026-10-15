import SwiftData
import SwiftUI
import UserNotifications

@main
struct SbuFuelApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer = {
        let defaults = UserDefaults.standard
        // fastlane snapshot shows the made-up car, never the user's own.
        if defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_SAMPLE_STORE") { return .preview }
        // UI flow tests start from an empty store of their own, never the user's.
        if defaults.bool(forKey: "SBU_EMPTY_STORE"), let container = try? ModelContainer.fuel(inMemory: true) {
            return container
        }
        do {
            return try ModelContainer.fuel()
        } catch {
            fatalError("Fuel store failed to open: \(error)")
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
