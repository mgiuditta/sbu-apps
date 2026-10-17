import SbuKit
import SwiftUI

/// The player, the app's one screen: the title, the ☰ categories, swipe between sounds or mixes
/// whose name is the figure, the original's controls below, and its bottom bar of actions that
/// open sheets over the player rather than switching tabs. When a timer stops the sound, the
/// figure closes on "Spento".
struct MainView: View {
    let model: PlayerModel
    let timers: TimersModel
    let alarms: AlarmsModel

    @State private var infoSound: Sound?
    @State private var isShowingTimers = false
    @State private var isCreatingMix = false
    @State private var isManaging = false
    @State private var isShowingClock = false
    @State private var editingMix: Mix?
    /// The Closure on the figure while it plays.
    @State private var isClosing = false
    /// The timer stop the player already closed on, or let pass because the app came back late.
    @State private var closedStop: Date?

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            SbuScreenTitle("Rumore", cartiglio: cartiglio)
                .padding(.horizontal, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space2)
            Group {
                if let next = timers.next {
                    TimerStatusLine(date: next.date) { isShowingTimers = true }
                }
                if let next = alarms.next {
                    AlarmStatusLine(date: next.date) { isShowingTimers = true }
                }
            }
            // Status lines and the control row are chrome: they stop growing before the page does.
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            let items = model.items
            Group {
                if items.isEmpty {
                    EmptyCategoryView(category: model.category) { isCreatingMix = true }
                } else {
                    TabView(selection: $model.index) {
                        ForEach(items.indices, id: \.self) { index in
                            // Only the page on screen sets its full stop: one per screen.
                            PlayerPage(item: items[index], position: index + 1, count: items.count, isPlaying: model.isPlaying && index == model.index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    // A new category starts a new set of pages.
                    .id(model.category)
                }
            }
            .sbuClosure($isClosing, word: "Spento")

            PlayerControls(model: model) {
                switch model.current {
                case .sound(let sound): infoSound = sound
                case .mix(let mix): editingMix = mix
                case nil: break
                }
            }
                .padding(.horizontal, SbuTheme.space4)
                .padding(.bottom, SbuTheme.space6)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu("Categorie", systemImage: "line.3.horizontal") {
                    Picker("Categorie", selection: $model.category) {
                        Section {
                            ForEach(PlayerCategory.lists) { category in
                                CategoryLabel(category: category).tag(category)
                            }
                        }
                        Section("Gruppi") {
                            ForEach(SoundCategory.allCases) { group in
                                CategoryLabel(category: .group(group)).tag(PlayerCategory.group(group))
                            }
                        }
                    }
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                // ponytail: the recorder and the generator join this menu with their tickets.
                Menu("Crea", systemImage: "plus") {
                    Button("Nuovo mix", systemImage: "square.stack.3d.up") { isCreatingMix = true }
                }
                Spacer()
                Button("Gestisci", systemImage: "square.grid.2x2") { isManaging = true }
                Spacer()
                Button("Timer", systemImage: "clock") { isShowingTimers = true }
                Spacer()
                Button("Dormi", systemImage: "moon") { isShowingClock = true }
            }
        }
        .sheet(item: $infoSound) { sound in
            SoundInfoSheet(sound: sound)
        }
        .sheet(isPresented: $isManaging) {
            ManageSheet(model: model)
        }
        .sheet(isPresented: $isShowingTimers) {
            TimersSheet(timers: timers, alarms: alarms, sounds: model.sounds)
        }
        .sheet(isPresented: $isCreatingMix) {
            NewMixFlow(player: model)
        }
        // A sheet on screen would keep the ringing alarm from showing.
        .onChange(of: alarms.ringing?.id) { _, ringingID in
            guard ringingID != nil else { return }
            closeSheets()
        }
        .fullScreenCover(isPresented: $isShowingClock) {
            BedsideClockView(model: model, alarms: alarms)
        }
        .fullScreenCover(item: ringing) { alarm in
            AlarmRingingView(alarm: alarm, soundName: model.alarmSound(withID: alarm.soundID)?.name ?? Sound.alarmTones[0].name, snooze: alarms.snooze, stop: alarms.stop)
        }
        .onChange(of: timers.lastStop) {
            // In the background the stop waits for the app to come back.
            if scenePhase == .active { closeOnStop() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { closeOnStop() }
        }
        .sheet(item: $editingMix) { mix in
            NavigationStack {
                MixPadView(mix: mix, isNew: false, player: model)
            }
            .interactiveDismissDisabled()
        }
    }

    /// "Sbu · Rumore · Preferiti": the list the player is in.
    private var cartiglio: String {
        String(localized: "Sbu · Rumore · \(String(localized: model.category.title))")
    }

    /// Closes the figure on "Spento" once per timer stop, only if the stop is still recent: a
    /// sound that stopped while the app was away long ago needs no ceremony.
    private func closeOnStop() {
        guard let stop = timers.lastStop, stop != closedStop else { return }
        closedStop = stop
        if TimersModel.isRecent(stop, at: .now) { isClosing = true }
    }

    private func closeSheets() {
        infoSound = nil
        isShowingTimers = false
        isCreatingMix = false
        isManaging = false
        editingMix = nil
    }

    /// The ringing alarm; only its own buttons close it. Over the bedside clock it rings there.
    private var ringing: Binding<SoundAlarm?> {
        Binding { isShowingClock ? nil : alarms.ringing } set: { _ in }
    }
}

#Preview("Light") {
    NavigationStack { MainView(model: PlayerModel(), timers: .preview, alarms: .preview(player: PlayerModel())) }
        .environment(\.sbuAccent, .noise)
}

#Preview("Dark") {
    NavigationStack { MainView(model: PlayerModel(), timers: .preview, alarms: .preview(player: PlayerModel())) }
        .environment(\.sbuAccent, .noise)
        .preferredColorScheme(.dark)
}
