import SwiftUI

@main
struct SbuHabitsApp: App {
    // Created once here: a view's initializer can run many times.
    @State private var model: HabitsModel
    @State private var sync: HabitsSync

    init() {
        let model = HabitsModel()
        // At every launch, the ones HealthKit makes in the background too, before any view.
        model.observeHealth()
        let sync = HabitsSync.live(model: model)
        sync.start()
        _model = State(initialValue: model)
        _sync = State(initialValue: sync)
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, sync: sync)
        }
    }
}
