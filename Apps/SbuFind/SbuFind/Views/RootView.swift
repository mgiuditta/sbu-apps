import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell. The scan runs only while the app is in the foreground.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var model: ScanModel

    init(model: ScanModel = ScanModel()) {
        _model = State(initialValue: model)
    }

    var body: some View {
        SbuAppShell("Sbu Find", slug: "find", accent: SbuTheme.accentFind, appIcon: Image(.appIconArtwork), settingsButtonPlacement: .content) {
            MainView(model: model)
        } settings: {
            ListSection(model: model)
            FeedbackSection(model: model)
        }
        .task(id: scenePhase == .active) {
            guard scenePhase == .active else { return }
            await model.run()
        }
    }
}

#Preview("Light") {
    RootView(model: ScanModel(scanner: FixedScanner()))
}

#Preview("Dark") {
    RootView(model: ScanModel(scanner: FixedScanner()))
        .preferredColorScheme(.dark)
}
