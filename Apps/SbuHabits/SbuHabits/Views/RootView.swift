import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    let model: HabitsModel

    @State private var sheet: HabitSheet?

    var body: some View {
        SbuAppShell("Sbu Habits", slug: "habits", accent: SbuTheme.accentHabits, field: SbuTheme.fieldHabits, appIcon: Image(.appIconArtwork)) {
            MainView(model: model, present: present)
        } settings: {
            StartOfDaySection(model: model)
        }
        // Outside the shell's dark field, so the form follows the system color scheme.
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
