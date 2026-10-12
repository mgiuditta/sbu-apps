import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @State private var model = LevelModel()

    var body: some View {
        SbuAppShell("Sbu Level", accent: SbuTheme.accentLevel, onAccent: SbuTheme.onAccentLevel, field: SbuTheme.fieldLevel, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
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
