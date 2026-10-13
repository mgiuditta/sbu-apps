import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let model: HabitsModel

    @State private var sheet: HabitSheet?
    /// Follows the model: the Timer stays on screen while a countdown runs or is paused.
    @State private var isShowingTimer = false

    var body: some View {
        SbuAppShell("Sbu Habits", slug: "habits", accent: SbuTheme.accentHabits, appIcon: Image(.appIconArtwork)) {
            MainView(model: model, present: present)
        } settings: {
            StartOfDaySection(model: model)
            DataSection(model: model)
        }
        .sheet(item: $sheet) { sheet in
            Group {
                switch sheet {
                case .add:
                    HabitForm(model: model)
                case .edit(let habit):
                    HabitForm(model: model, editing: habit)
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
        // A countdown that ends with the app open.
        .sensoryFeedback(.success, trigger: model.timersEnded)
    }

    private func present(_ sheet: HabitSheet) {
        self.sheet = sheet
    }
}

#Preview("Light") {
    RootView(model: .preview)
}

#Preview("Dark") {
    RootView(model: .preview)
        .preferredColorScheme(.dark)
}
