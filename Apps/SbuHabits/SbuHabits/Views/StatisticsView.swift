import SbuKit
import SwiftUI

/// Statistiche: every habit with its Serie, in the grid's order, reordered by dragging.
struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.habits) { habit in
                    NavigationLink(value: habit.id) {
                        StatisticsRow(habit: habit, streak: model.streak(of: habit))
                    }
                }
                .onMove(perform: model.move)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Statistiche")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: UUID.self) { id in
                if let habit = model.habits.first(where: { $0.id == id }) {
                    HabitDetailView(model: model, habit: habit)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
    }

    private func close() {
        dismiss()
    }
}

private struct StatisticsRow: View {
    let habit: Habit
    let streak: Int

    var body: some View {
        LabeledContent {
            Text(habit.schedule.streakText(streak))
                .monospacedDigit()
        } label: {
            Label {
                Text(habit.title)
            } icon: {
                Image(systemName: habit.symbol)
                    .fontWeight(.medium)
                    .imageScale(.medium)
            }
        }
    }
}

#Preview("Light") {
    StatisticsView(model: .preview)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    StatisticsView(model: .preview)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
