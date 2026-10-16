import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell. The scan runs only while the app is in the foreground.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var model: ScanModel
    @State private var ringer: HeadphoneRinger

    init(model: ScanModel = ScanModel(), ringer: HeadphoneRinger = .requested(in: .standard)) {
        _model = State(initialValue: model)
        _ringer = State(initialValue: ringer)
    }

    var body: some View {
        SbuAppShell("Sbu Find", slug: "find", accent: SbuTheme.accentFind, appIcon: Image(.appIconArtwork), settingsButtonPlacement: .content) {
            MainView(model: model, ringer: ringer)
        } settings: {
            ListSection(model: model)
            FeedbackSection(model: model)
            PlacesSection(model: model)
            #if DEBUG
            TuningSection(model: model)
            #endif
        }
        .task(id: scenePhase == .active) {
            guard scenePhase == .active else { return }
            await model.run()
        }
        .task {
            await ringer.followRoute()
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
