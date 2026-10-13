import SwiftUI

@main
struct SbuNoiseApp: App {
    @State private var model: PlayerModel
    @State private var timers: TimersModel
    private let systemAudio: SystemAudio

    init() {
        let model = PlayerModel()
        _model = State(initialValue: model)
        _timers = State(initialValue: TimersModel(player: model))
        systemAudio = SystemAudio(model: model)
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, timers: timers)
        }
    }
}
