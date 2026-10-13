import SwiftUI

@main
struct SbuNoiseApp: App {
    @State private var model: PlayerModel
    @State private var timers: TimersModel
    private let systemAudio: SystemAudio
    private let widgetSync: WidgetSync

    init() {
        let model = PlayerModel()
        _model = State(initialValue: model)
        _timers = State(initialValue: TimersModel(player: model))
        systemAudio = SystemAudio(model: model)
        widgetSync = WidgetSync(model: model)
        // Here and not in a view: an intent can launch the app in the background, with no UI.
        PlaybackCommands.handler = { [model] in model.perform($0) }
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, timers: timers)
        }
    }
}
