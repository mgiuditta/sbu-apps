import SwiftUI

@main
struct SbuHabitsApp: App {
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate

    // Created once here: a view's initializer can run many times.
    @State private var model: HabitsModel
    @State private var sync: HabitsSync
    @State private var sharing: HabitSharing
    @State private var received: ReceivedHabits
    @State private var watch: WatchLink

    init() {
        let model = HabitsModel()
        // At every launch, the ones HealthKit makes in the background too, before any view.
        model.observeHealth()
        let sync = HabitsSync.live(model: model)
        sync.start()
        let received = ReceivedHabits.live()
        // Before any silent notification or invitation, which can launch the app in the background.
        AppDelegate.received = received
        // The Live Activity's Pausa and Riprendi run here, also with the app in the background.
        TimerControl.reloadApp = { model.reload() }
        // At every launch too: a tap on the Apple Watch can wake the app in the background.
        _watch = State(initialValue: WatchLink.live(model: model))
        _model = State(initialValue: model)
        _sync = State(initialValue: sync)
        _sharing = State(initialValue: HabitSharing.live(model: model))
        _received = State(initialValue: received)
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, sync: sync, sharing: sharing, received: received)
        }
    }
}
