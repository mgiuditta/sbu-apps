import SbuKit
import SwiftUI

/// The sheet that edits a habit: its form in a navigation stack of its own, with Annulla.
struct HabitForm: View {
    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel
    let habit: Habit

    init(model: HabitsModel, editing habit: Habit) {
        self.model = model
        self.habit = habit
    }

    var body: some View {
        NavigationStack {
            HabitFormScreen(model: model, editing: habit, close: close)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla", action: close)
                    }
                }
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    let model = HabitsModel.preview
    HabitForm(model: model, editing: model.habits[0])
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    HabitForm(model: model, editing: model.habits[1])
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
