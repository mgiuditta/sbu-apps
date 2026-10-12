import SbuKit
import SwiftUI
import WidgetKit

/// One habit's ring, big enough to tap, with its title and Serie.
struct SingleHabitWidgetView: View {
    let entry: SingleHabitEntry

    var body: some View {
        Group {
            if let habit = entry.habit, let progress = entry.progress {
                Button(intent: MarkHabitIntent(habitID: habit.id)) {
                    VStack(spacing: SbuTheme.space1) {
                        HabitRing(symbol: progress.isComplete ? "checkmark" : habit.symbol, segments: max(progress.goal, 1), filled: Double(progress.done))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Text(habit.title)
                            .font(SbuTheme.caption)
                            .foregroundStyle(SbuTheme.onField)
                            .lineLimit(1)

                        Text(habit.schedule.isWeekly ? "\(entry.streak) settimane" : "\(entry.streak) giorni")
                            .font(SbuTheme.caption)
                            .monospacedDigit()
                            .foregroundStyle(SbuTheme.onFieldMuted)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(habit.title)
                .accessibilityValue(progress.isComplete ? Text("Fatta") : Text("\(progress.done) di \(progress.goal)"))
            } else {
                Text("Aggiungi un'abitudine nell'app")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.onFieldMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
        .containerBackground(for: .widget) {
            SbuTheme.fieldHabits
        }
    }
}

#Preview("Small", as: .systemSmall) {
    SingleHabitWidget()
} timeline: {
    SingleHabitEntry.sample
}
