import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let model: PlayerModel
    let timers: TimersModel

    var body: some View {
        SbuAppShell("Sbu Noise", slug: "noise", accent: SbuTheme.accentNoise, appIcon: Image(.appIconArtwork)) {
            MainView(model: model, timers: timers)
        } settings: {
            EmptyView()
        }
    }
}

#Preview("Light") {
    RootView(model: PlayerModel(), timers: .preview)
}

#Preview("Dark") {
    RootView(model: PlayerModel(), timers: .preview)
        .preferredColorScheme(.dark)
}
