import SbuKit
import SwiftUI

/// The tool screen: the Serie piena as the figure, today's habits in a grid, and Aggiungi.
struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: HabitsModel
    let add: () -> Void

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
            HabitGrid(model: model)
        } pills: {
            Button("Aggiungi", action: add)
                .buttonStyle(SbuFieldPillStyle())
        }
        // Rolls the figure's digits (SbuToolField sets .numericText) when the Serie piena changes.
        .animation(reduceMotion ? nil : .snappy, value: model.fullStreak)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.reload()
            }
        }
    }
}

#Preview("Light") {
    MainView(model: .preview) {}
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    MainView(model: .preview) {}
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
