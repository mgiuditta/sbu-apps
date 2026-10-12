import SbuKit
import SwiftUI

/// The tool screen: the Serie piena as the figure, today's habits in a grid, and Aggiungi.
struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: HabitsModel
    let present: (HabitSheet) -> Void

    /// The word after the figure. Two strings, as Xcode asks for plurals that omit the number.
    private var unit: String {
        " " + (model.fullStreak == 1 ? String(localized: "giorno") : String(localized: "giorni"))
    }

    private var context: LocalizedStringKey? {
        if model.habits.isEmpty {
            "Aggiungi la prima abitudine"
        } else if model.todayHabits.isEmpty {
            "Niente previsto oggi"
        } else {
            nil
        }
    }

    var body: some View {
        SbuToolField(
            "Serie piena",
            value: model.fullStreak,
            format: .number,
            unit: unit,
            context: context
        ) {
            HabitGrid(model: model, edit: edit)
        } pills: {
            Button("Aggiungi", action: add)
                .buttonStyle(SbuFieldPillStyle())
            Button("Statistiche", action: showStatistics)
                .buttonStyle(SbuFieldPillStyle())
                .disabled(model.habits.isEmpty)
        }
        // Rolls the figure's digits (SbuToolField sets .numericText) when the Serie piena changes.
        .animation(reduceMotion ? nil : .snappy, value: model.fullStreak)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.reload()
            }
        }
    }

    private func add() {
        present(.add)
    }

    private func edit(_ habit: Habit) {
        present(.edit(habit))
    }

    private func showStatistics() {
        present(.statistics)
    }
}

#Preview("Light") {
    MainView(model: .preview) { _ in }
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    MainView(model: .preview) { _ in }
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
