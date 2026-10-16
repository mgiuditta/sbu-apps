import SwiftUI

@main
struct SbuFindApp: App {
    private let model: ScanModel
    private let ringer: HeadphoneRinger

    /// The scan starts here, not in a view: iOS can relaunch the app in the background for a saved
    /// device, and then no view is built. Core Bluetooth must be set up again at every launch.
    init() {
        let model = ScanModel()
        self.model = model
        ringer = .requested(in: .standard)
        Task {
            await model.run()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, ringer: ringer)
        }
    }
}
