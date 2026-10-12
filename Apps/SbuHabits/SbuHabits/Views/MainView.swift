import SbuKit
import SwiftUI

/// The tool screen: the Serie piena as the figure, today's habits in a grid, and Aggiungi.
struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: HabitsModel
    let present: (HabitSheet) -> Void

    private var context: LocalizedStringKey? {
        if model.isUnreadable {
            "Non riesco a leggere le abitudini salvate"
        } else if model.habits.isEmpty {
            "Aggiungi la prima abitudine"
        } else if model.todayHabits.isEmpty {
            "Niente previsto oggi"
        } else {
            nil
        }
    }

    var body: some View {
        // Walks back through the whole log: once per render.
        let fullStreak = model.fullStreak
        SbuToolField(
            "Serie piena",
            value: fullStreak,
            format: .number,
            unit: Self.unit(for: fullStreak),
            context: context
        ) {
            HabitGrid(model: model, edit: edit)
        } pills: {
            Button("Aggiungi", action: add)
                .buttonStyle(SbuFieldPillStyle())
                .disabled(model.isUnreadable)
            Button("Statistiche", action: showStatistics)
                .buttonStyle(SbuFieldPillStyle())
                .disabled(model.habits.isEmpty)
        }
        // Rolls the figure's digits (SbuToolField sets .numericText) when the Serie piena changes.
        .animation(reduceMotion ? nil : .snappy, value: fullStreak)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.reload()
            }
        }
        // Moves the grid to the new day while the app stays open.
        .task(id: model.today) {
            try? await Task.sleep(for: .seconds(max(model.nextDayStart.timeIntervalSinceNow, 1)))
            if Task.isCancelled == false {
                model.reload()
            }
        }
    }

    /// The word after the figure. Two strings, as Xcode asks for plurals that omit the number.
    private static func unit(for streak: Int) -> String {
        " " + (streak == 1 ? String(localized: "giorno") : String(localized: "giorni"))
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
