import SwiftData
import SwiftUI

@main
struct SbuSubscriptionsApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer = {
        // fastlane snapshot shows made-up subscriptions, never the user's own.
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") { return .preview }
        do {
            return try .subscriptions()
        } catch {
            fatalError("Subscriptions store failed to open: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
