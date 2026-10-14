import SwiftData
import SwiftUI

@main
struct SbuScannerApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the history.
    private let container: ModelContainer = {
        // fastlane snapshot and the flow tests show made-up codes, never the user's own.
        if LaunchMode.isDemo { return .preview }
        do {
            let container = try ModelContainer.scanner()
            // Before the first screen: whoever updates from the 1.x finds their history and folders there.
            LegacyMigration.runIfNeeded(container.mainContext)
            return container
        } catch {
            fatalError("Scanner store failed to open: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
