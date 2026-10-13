import SbuKit
import SwiftUI
import WidgetKit

/// One habit's ring, big enough to tap, with its title and Serie.
struct SingleHabitWidgetView: View {
    let entry: SingleHabitEntry

    var body: some View {
        Group {
            if let habit = entry.habit, let progress = entry.progress {
                let face = HabitRingFace(habit: habit, progress: progress)
                let streakText = Text(habit.schedule.streakText(entry.streak))
                Button(intent: MarkHabitIntent(habitID: habit.id)) {
                    VStack(spacing: SbuTheme.space1) {
                        HabitRing(face: face)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Text(habit.title)
                            .font(SbuTheme.caption)
                            .foregroundStyle(SbuTheme.ink)
                            .lineLimit(1)

                        streakText
                            .font(SbuTheme.caption)
                            .monospacedDigit()
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                }
                .buttonStyle(.plain)
                // The same as the app's cell: kind, count and Limite, then the Serie.
                .accessibilityLabel(habit.title)
                .accessibilityValue(face.progressText + Text(verbatim: ", ") + streakText)
            } else {
                Text("Aggiungi un'abitudine nell'app")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .tint(SbuTheme.accentHabits)
        .containerBackground(for: .widget) {
            SbuTheme.surface
        }
    }
}

#Preview("Small", as: .systemSmall) {
    SingleHabitWidget()
} timeline: {
    SingleHabitEntry.sample
    SingleHabitEntry.overLimitSample
}
