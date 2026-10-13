import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase

    let model: HabitsModel
    let sync: HabitsSync

    @State private var sheet: HabitSheet?
    /// Follows the model: the Timer stays on screen while a countdown runs or is paused.
    @State private var isShowingTimer = false

    var body: some View {
        SbuAppShell("Sbu Habits", slug: "habits", accent: SbuTheme.accentHabits, appIcon: Image(.appIconArtwork), settingsButtonPlacement: .content) {
            // The gear sits at the bottom of the tool screen, as in Streaks.
            MainView(model: model, present: present)
        } settings: {
            StartOfDaySection(model: model)
            HabitOrderSection(model: model)
            DataSection(model: model, sync: sync)
        }
        .sheet(item: $sheet) { sheet in
            Group {
                switch sheet {
                case .add:
                    AddHabitSheet(model: model)
                case .edit(let habit):
                    HabitForm(model: model, editing: habit)
                case .note(let habit, let day):
                    DailyNoteEditor(model: model, habit: habit, day: day)
                case .statistics:
                    StatisticsView(model: model)
                }
            }
            .tint(SbuTheme.accentHabits)
        }
        .fullScreenCover(isPresented: $isShowingTimer) {
            TimerView(model: model)
                .tint(SbuTheme.accentHabits)
        }
        .onChange(of: model.timer != nil, initial: true) { _, hasTimer in
            isShowingTimer = hasTimer
        }
        // Another iPhone may have synced meanwhile; a change still waiting goes before the app sleeps.
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                Task {
                    await sync.appDidBecomeActive()
                }
            case .background:
                sync.appDidEnterBackground()
            default:
                break
            }
        }
        // A countdown that ends with the app open.
        .sensoryFeedback(.success, trigger: model.timersEnded)
    }

    private func present(_ sheet: HabitSheet) {
        self.sheet = sheet
    }
}

#Preview("Light") {
    RootView(model: .preview, sync: .preview(model: .preview))
}

#Preview("Dark") {
    RootView(model: .preview, sync: .preview(model: .preview))
        .preferredColorScheme(.dark)
}
