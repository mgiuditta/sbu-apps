import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let model: HabitsModel

    @State private var sheet: HabitSheet?

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
