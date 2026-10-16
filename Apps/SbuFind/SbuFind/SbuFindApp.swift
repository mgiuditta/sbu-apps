import SwiftUI

@main
struct SbuFindApp: App {
    private let model: ScanModel
    private let ringer: HeadphoneRinger

    /// The scan starts here, not in a view: iOS can relaunch the app in the background for a saved
    /// device, and then no view is built. Core Bluetooth must be set up again at every launch.
    init() {
        // Relaunched by iOS for a saved device, the app starts in the background with no scene.
        let model = ScanModel(isForeground: UIApplication.shared.applicationState != .background)
        self.model = model
        ringer = .requested(in: .standard)
        Task {
            await model.run()
        }
        // Launched before the first unlock, the saved files could not be read: read them now.
        Task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.protectedDataDidBecomeAvailableNotification) {
                model.reloadUnavailableFiles()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, ringer: ringer)
        }
    }
}
