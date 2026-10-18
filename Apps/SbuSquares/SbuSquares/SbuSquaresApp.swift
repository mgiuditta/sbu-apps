import SwiftUI

@main
struct SbuSquaresApp: App {
    init() {
        #if DEBUG
        // UI tests start from an empty game and no Record.
        if ProcessInfo.processInfo.arguments.contains("-resetForUITests"), let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
