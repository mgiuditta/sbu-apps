import SbuKit
import SwiftUI

/// The player, the app's one screen: swipe between sounds, the original's controls below, and its
/// bottom bar of actions that open sheets over the player rather than switching tabs.
struct MainView: View {
    let model: PlayerModel

    @State private var infoSound: Sound?

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            TabView(selection: $model.index) {
                ForEach(model.sounds.indices, id: \.self) { index in
                    SoundPage(sound: model.sounds[index], position: index + 1, count: model.sounds.count)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            PlayerControls(model: model) { infoSound = model.current }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space6)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                // ponytail: disabled until each action's ticket wires its sheet.
                Button("Crea", systemImage: "plus") {}.disabled(true)
                Spacer()
                Button("Gestisci", systemImage: "square.grid.2x2") {}.disabled(true)
                Spacer()
                Button("Timer", systemImage: "clock") {}.disabled(true)
                Spacer()
                Button("Dormi", systemImage: "moon") {}.disabled(true)
            }
        }
        .sheet(item: $infoSound) { sound in
            SoundInfoSheet(sound: sound)
        }
    }
}

#Preview("Light") {
    NavigationStack { MainView(model: PlayerModel()) }
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    NavigationStack { MainView(model: PlayerModel()) }
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
