import SbuKit
import SwiftUI

/// One habit's page: its Serie as the figure, the best one, and its history.
struct HabitDetailView: View {
    let model: HabitsModel
    let habit: Habit

    private var unit: String {
        let streak = model.streak(of: habit)
        let word = if habit.schedule.isWeekly {
            streak == 1 ? String(localized: "settimana") : String(localized: "settimane")
        } else {
            streak == 1 ? String(localized: "giorno") : String(localized: "giorni")
        }
        return " " + word
    }

    var body: some View {
        List {
            Section {
                SbuStat("Serie", value: model.streak(of: habit), format: .number, unit: unit, context: "Serie migliore: \(model.bestStreak(of: habit))")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section("Storico") {
                HistoryGrid(habit: habit, today: model.today, firstWeekday: model.firstWeekday)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text(habit.title))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    let model = HabitsModel.preview
    NavigationStack {
        HabitDetailView(model: model, habit: model.habits[1])
    }
    .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    NavigationStack {
        HabitDetailView(model: model, habit: model.habits[1])
    }
    .tint(SbuTheme.accentHabits)
    .preferredColorScheme(.dark)
}
