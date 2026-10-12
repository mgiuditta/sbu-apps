import SbuKit
import SwiftUI

/// Today's habits in two columns on the field.
struct HabitGrid: View {
    private static let columns = [GridItem(.flexible(), spacing: SbuTheme.space3), GridItem(.flexible(), spacing: SbuTheme.space3)]

    let model: HabitsModel

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Self.columns, spacing: SbuTheme.space3) {
                ForEach(model.habits) { habit in
                    HabitCell(
                        habit: habit,
                        streak: model.streak(of: habit),
                        isDone: habit.isDone(on: model.today),
                        markDone: { model.markDone(habit) },
                        undoLast: { model.undoLast(habit) }
                    )
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview("Light") {
    HabitGrid(model: .preview)
        .padding(SbuTheme.space4)
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    HabitGrid(model: .preview)
        .padding(SbuTheme.space4)
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
