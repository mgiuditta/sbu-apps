import SwiftUI

@main
struct SbuNoiseApp: App {
    @State private var model: PlayerModel
    private let systemAudio: SystemAudio

    init() {
        let model = PlayerModel()
        _model = State(initialValue: model)
        systemAudio = SystemAudio(model: model)
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
    }
}
