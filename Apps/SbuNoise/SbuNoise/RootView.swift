import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let model: PlayerModel
    let timers: TimersModel
    let alarms: AlarmsModel

    var body: some View {
        SbuAppShell("Sbu Noise", slug: "noise", accent: SbuTheme.accentNoise, appIcon: Image(.appIconArtwork)) {
            MainView(model: model, timers: timers, alarms: alarms)
        } settings: {
            Section {
                NavigationLink("Crediti dei suoni") {
                    SoundCreditsView(sounds: model.sounds)
                }
            }
        }
    }
}

#Preview("Light") {
    RootView(model: PlayerModel(), timers: .preview, alarms: .preview(player: PlayerModel()))
}

#Preview("Dark") {
    RootView(model: PlayerModel(), timers: .preview, alarms: .preview(player: PlayerModel()))
        .preferredColorScheme(.dark)
}
