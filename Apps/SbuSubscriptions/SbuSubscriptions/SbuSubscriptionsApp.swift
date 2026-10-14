import SwiftData
import SwiftUI

@main
struct SbuSubscriptionsApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer = {
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
