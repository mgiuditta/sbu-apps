import SwiftData
import SwiftUI

@main
struct SbuLibrettoApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the libretto.
    private let container: ModelContainer = {
        let defaults = UserDefaults.standard
        // fastlane snapshot shows the made-up libretto, never the user's own.
        if defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_SAMPLE_STORE") { return .preview }
        // UI flow tests start from an empty store of their own, never the user's.
        if defaults.bool(forKey: "SBU_EMPTY_STORE"), let container = try? ModelContainer.libretto(inMemory: true) {
            return container
        }
        do {
            return try ModelContainer.libretto()
        } catch {
            fatalError("Libretto store failed to open: \(error)")
        }
    }()

    /// Made once: in a demo launch it starts from fresh settings.
    @State private var settings = LaunchMode.current.courseSettings()

    var body: some Scene {
        WindowGroup {
            RootView(settings: settings)
        }
        .modelContainer(container)
    }
}
