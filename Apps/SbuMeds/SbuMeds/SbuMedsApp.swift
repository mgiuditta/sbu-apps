import SwiftData
import SwiftUI

@main
struct SbuMedsApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer = {
        // fastlane snapshot shows the made-up family, never the user's own.
        if Launch.isSnapshot { return .sample(now: Launch.snapshotNow) }
        // UI flow tests start from an empty store of their own.
        if Launch.isEmptyStore, let container = try? ModelContainer.meds(inMemory: true) { return container }
        do {
            return try ModelContainer.meds()
        } catch {
            fatalError("Meds store failed to open: \(error)")
        }
    }()

    init() {
        Launch.resetDemoPreferences()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
