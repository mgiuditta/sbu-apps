import SwiftUI

@main
struct SbuCleanApp: App {
    @State private var model = AppLaunch.makeModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
    }
}
