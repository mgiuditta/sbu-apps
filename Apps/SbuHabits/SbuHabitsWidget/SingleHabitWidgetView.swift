import SbuKit
import SwiftUI
import WidgetKit

/// One habit's Serie as the widget's figure, under the habit's title; the full stop is set once
/// today is done. A tap marks it once with `MarkHabitIntent`, as the checkbox does in the app; an
/// Abitudine a tempo is marked done without its Timer.
struct SingleHabitWidgetView: View {
    let entry: SingleHabitEntry

    var body: some View {
        if let habit = entry.habit, let progress = entry.progress {
            Button(intent: MarkHabitIntent(habitID: habit.id)) {
                SbuWidgetFigure(
                    value: entry.streak.formatted(),
                    label: Text(habit.title),
                    fullStop: progress.limit == nil && progress.isComplete ? .set : .waiting,
                    accent: .habits
                )
            }
            // Not disabled, which would dim a done habit: marking it again changes nothing. An
            // Abitudine da evitare counts one more time given in on every tap.
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(habit.title)
            .accessibilityValue(accessibilityValue(habit, progress: progress))
            .accessibilityAddTraits(.isButton)
        } else {
            SbuWidgetFigure(value: 0.formatted(), label: Text("Aggiungi un'abitudine nell'app"), fullStop: .waiting, accent: .habits)
        }
    }

    /// Today's state, then the Serie, as the app's row reads it.
    private func accessibilityValue(_ habit: Habit, progress: HabitProgress) -> Text {
        HabitRingFace(habit: habit, progress: progress).progressText + Text(verbatim: ", ") + Text(habit.schedule.streakText(entry.streak))
    }
}

// The canvas switches light, dark and tinted.
#Preview("Small", as: .systemSmall) {
    SingleHabitWidget()
} timeline: {
    SingleHabitEntry.sample
    SingleHabitEntry.overLimitSample
}
