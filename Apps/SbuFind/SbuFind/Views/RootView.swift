import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell. The scan runs for the whole life of the app; the scene
/// phase tells it when the app is in front and when it is in the background.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase

    let model: ScanModel
    let ringer: HeadphoneRinger

    var body: some View {
        SbuAppShell("Sbu Find", slug: "find", accent: .find, appIcon: Image(.appIconArtwork), settingsButtonPlacement: .content) {
            MainView(model: model, ringer: ringer)
        } settings: {
            ListSection(model: model)
            FeedbackSection(model: model)
            PlacesSection(model: model)
            #if DEBUG
            if !UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
                TuningSection(model: model)
            }
            #endif
        }
        .onChange(of: scenePhase, initial: true, phaseChanged)
        .task {
            await ringer.followRoute()
        }
    }

    /// Inactive, as under Control Center, still counts as in front: only background changes the scan.
    private func phaseChanged() {
        model.setForeground(scenePhase != .background)
    }
}

#Preview("Light") {
    RootViewPreview()
}

#Preview("Dark") {
    RootViewPreview()
        .preferredColorScheme(.dark)
}

private struct RootViewPreview: View {
    @State private var model = ScanModel(scanner: FixedScanner(), notifier: AcceptingLostNotifier(), location: FixedLocationProvider())
    @State private var ringer = HeadphoneRinger(route: FixedAudio(), player: FixedAudio())

    var body: some View {
        RootView(model: model, ringer: ringer)
            .task { await model.run() }
    }
}
