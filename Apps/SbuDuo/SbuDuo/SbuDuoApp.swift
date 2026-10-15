import SwiftData
import SwiftUI

@main
struct SbuDuoApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer = {
        // fastlane snapshot shows made-up gifts, never the user's own.
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") { return .duoPreview }
        do {
            return try .duo()
        } catch {
            fatalError("Duo store failed to open: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
