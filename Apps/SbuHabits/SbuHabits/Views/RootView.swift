import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell.
struct RootView: View {
    @State private var model: HabitsModel
    @State private var isAdding = false

    init(model: HabitsModel = HabitsModel()) {
        _model = State(initialValue: model)
    }

    var body: some View {
        SbuAppShell("Sbu Habits", accent: SbuTheme.accentHabits, field: SbuTheme.fieldHabits, appIcon: Image(.appIconArtwork)) {
            MainView(model: model, add: showAdd)
        } settings: {
            StartOfDaySection(model: model)
        }
        // Outside the shell's dark field, so the form follows the system color scheme.
        .sheet(isPresented: $isAdding) {
            AddHabitView(model: model)
                .tint(SbuTheme.accentHabits)
        }
    }

    private func showAdd() {
        isAdding = true
    }
}

#Preview("Light") {
    RootView(model: .preview)
}

#Preview("Dark") {
    RootView(model: .preview)
        .preferredColorScheme(.dark)
}
