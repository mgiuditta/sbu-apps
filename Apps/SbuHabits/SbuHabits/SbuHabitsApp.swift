import SwiftUI

@main
struct SbuHabitsApp: App {
    // Created once here: a view's initializer can run many times.
    @State private var model = HabitsModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
    }
}
