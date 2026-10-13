import SbuKit
import SwiftUI

/// Crea → Nuovo mix, as in the original: first up to five sounds, then the Mix Pad.
struct NewMixFlow: View {
    let player: PlayerModel

    @Environment(\.dismiss) private var dismiss
    @State private var mix: Mix?

    var body: some View {
        NavigationStack {
            MixSoundPicker(sounds: player.sounds, limit: Mix.maxLayers, confirmTitle: "Avanti") { soundIDs in
                mix = Mix(name: player.library.newMixName(), soundIDs: soundIDs)
            }
            .navigationDestination(item: $mix) { mix in
                MixPadView(mix: mix, isNew: true, player: player) { dismiss() }
            }
        }
        .interactiveDismissDisabled(mix != nil)
    }
}

#Preview("Light") {
    NewMixFlow(player: PlayerModel())
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    NewMixFlow(player: PlayerModel())
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
