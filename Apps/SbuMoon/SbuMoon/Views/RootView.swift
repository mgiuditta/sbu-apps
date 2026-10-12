import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @State private var model = MoonModel()

    var body: some View {
        SbuAppShell("Sbu Moon", slug: "moon", accent: SbuTheme.accentMoon, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
            CalculationSection()
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
