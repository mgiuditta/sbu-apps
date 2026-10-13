import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @State private var model = PlayerModel()

    var body: some View {
        SbuAppShell("Sbu Noise", slug: "noise", accent: SbuTheme.accentNoise, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
            EmptyView()
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
