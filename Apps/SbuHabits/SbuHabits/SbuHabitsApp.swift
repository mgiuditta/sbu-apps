import SwiftUI

@main
struct SbuHabitsApp: App {
    // Created once here: a view's initializer can run many times.
    @State private var model: HabitsModel

    init() {
        let model = HabitsModel()
        // At every launch, the ones HealthKit makes in the background too, before any view.
        model.observeHealth()
        // The Live Activity's Pausa and Riprendi run here, also with the app in the background.
        TimerControl.reloadApp = { model.reload() }
        _model = State(initialValue: model)
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
    }
}
