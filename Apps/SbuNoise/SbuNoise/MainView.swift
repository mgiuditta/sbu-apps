import SbuKit
import SwiftUI

/// The player, the app's one screen: the ☰ categories, swipe between sounds or mixes, the
/// original's controls below, and its bottom bar of actions that open sheets over the player
/// rather than switching tabs.
struct MainView: View {
    let model: PlayerModel
    let timers: TimersModel

    @State private var infoSound: Sound?
    @State private var isShowingTimers = false
    @State private var isCreatingMix = false
    @State private var editingMix: Mix?

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            if let next = timers.next {
                TimerStatusLine(date: next.date) { isShowingTimers = true }
            }
            let items = model.items
            if items.isEmpty {
                ContentUnavailableView {
                    Label("Nessun mix", systemImage: "square.stack.3d.up")
                } description: {
                    Text("Metti insieme fino a cinque suoni e scegli dove sentirli.")
                } actions: {
                    Button("Crea un mix") { isCreatingMix = true }
                        .frame(minHeight: SbuTheme.controlRoundSm)
                        .contentShape(.rect)
                }
            } else {
                TabView(selection: $model.index) {
                    ForEach(items.indices, id: \.self) { index in
                        PlayerPage(item: items[index], position: index + 1, count: items.count)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // A new category starts a new set of pages.
                .id(model.category)
            }

            PlayerControls(model: model) {
                switch model.current {
                case .sound(let sound): infoSound = sound
                case .mix(let mix): editingMix = mix
                case nil: break
                }
            }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space6)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu("Categorie", systemImage: "line.3.horizontal") {
                    Picker("Categorie", selection: $model.category) {
                        Label("Suoni", systemImage: "waveform").tag(PlayerCategory.sounds)
                        Label("Mix", systemImage: "square.stack.3d.up").tag(PlayerCategory.mixes)
                    }
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                // ponytail: the recorder and the generator join this menu with their tickets.
                Menu("Crea", systemImage: "plus") {
                    Button("Nuovo mix", systemImage: "square.stack.3d.up") { isCreatingMix = true }
                }
                Spacer()
                Button("Gestisci", systemImage: "square.grid.2x2") {}.disabled(true)
                Spacer()
                Button("Timer", systemImage: "clock") { isShowingTimers = true }
                Spacer()
                Button("Dormi", systemImage: "moon") {}.disabled(true)
            }
        }
        .sheet(item: $infoSound) { sound in
            SoundInfoSheet(sound: sound)
        }
        .sheet(isPresented: $isShowingTimers) {
            TimersSheet(timers: timers)
        }
        .sheet(isPresented: $isCreatingMix) {
            NewMixFlow(player: model)
        }
        .sheet(item: $editingMix) { mix in
            NavigationStack {
                MixPadView(mix: mix, isNew: false, player: model)
            }
            .interactiveDismissDisabled()
        }
    }
}

#Preview("Light") {
    NavigationStack { MainView(model: PlayerModel(), timers: .preview) }
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    NavigationStack { MainView(model: PlayerModel(), timers: .preview) }
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
