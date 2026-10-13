import SbuKit
import SwiftUI

/// The sheet that edits a habit: its form in a navigation stack of its own, with Annulla.
struct HabitForm: View {
    @Environment(\.dismiss) private var dismiss

    let model: HabitsModel
    let habit: Habit
    /// Offers Condividi in the form.
    let sharing: HabitSharing?

    init(model: HabitsModel, editing habit: Habit, sharing: HabitSharing? = nil) {
        self.model = model
        self.habit = habit
        self.sharing = sharing
    }

    var body: some View {
        NavigationStack {
            HabitFormScreen(model: model, editing: habit, sharing: sharing, close: close)
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
    HabitForm(model: model, editing: model.habits[0], sharing: .preview(model: model))
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    HabitForm(model: model, editing: model.habits[1], sharing: .preview(model: model, isAvailable: false))
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
