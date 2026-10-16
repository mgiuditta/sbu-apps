import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @State private var model = LevelModel()

    var body: some View {
        SbuAppShell("Sbu Level", slug: "level", accent: .level, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
            InfoSection()
            UnitSection(model: model)
            LockSection(model: model)
            VoiceSection(model: model)
            MeasureSection(model: model)
            CalibrationSection(model: model)
        }
    }
}

#Preview("Light") {
    RootView()
}

#Preview("Dark") {
    RootView()
        .preferredColorScheme(.dark)
}
