import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let model: PlayerModel

    var body: some View {
        SbuAppShell("Sbu Noise", slug: "noise", accent: SbuTheme.accentNoise, appIcon: Image(.appIconArtwork)) {
            MainView(model: model)
        } settings: {
            EmptyView()
        }
    }
}

#Preview("Light") {
    RootView(model: PlayerModel())
}

#Preview("Dark") {
    RootView(model: PlayerModel())
        .preferredColorScheme(.dark)
}
