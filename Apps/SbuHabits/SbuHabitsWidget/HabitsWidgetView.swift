import SbuKit
import SwiftUI
import WidgetKit

/// Today's habits as rings on the Habits field; tapping a ring marks it once.
struct HabitsWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: HabitsWidgetEntry

    private var limit: Int {
        family == .systemSmall ? 4 : 8
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: SbuTheme.space2), count: family == .systemSmall ? 2 : 4)
    }

    var body: some View {
        Group {
            if entry.habits.isEmpty {
                Text("Aggiungi un'abitudine nell'app")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.onFieldMuted)
                    .multilineTextAlignment(.center)
            } else {
                LazyVGrid(columns: columns, spacing: SbuTheme.space2) {
                    ForEach(entry.habits.prefix(limit)) { habit in
                        if let progress = entry.progress[habit.id] {
                            WidgetHabitButton(habit: habit, progress: progress, showsTitle: family != .systemSmall)
                        }
                    }
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
        .containerBackground(for: .widget) {
            SbuTheme.fieldHabits
        }
    }
}

private struct WidgetHabitButton: View {
    let habit: Habit
    let progress: HabitProgress
    let showsTitle: Bool

    var body: some View {
        Button(intent: MarkHabitIntent(habitID: habit.id)) {
            VStack(spacing: SbuTheme.space1) {
                HabitRing(symbol: progress.isComplete ? "checkmark" : habit.symbol, segments: max(progress.goal, 1), filled: Double(progress.done))
                    .widgetAccentable()

                if showsTitle {
                    Text(habit.title)
                        .font(SbuTheme.caption)
                        .foregroundStyle(SbuTheme.onField)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(progress.holdUndoes)
        .accessibilityLabel(habit.title)
        .accessibilityValue(progress.isComplete ? Text("Fatta") : Text("\(progress.done) di \(progress.goal)"))
    }
}

#Preview("Small", as: .systemSmall) {
    HabitsWidget()
} timeline: {
    HabitsWidgetEntry.sample
}

#Preview("Medium", as: .systemMedium) {
    HabitsWidget()
} timeline: {
    HabitsWidgetEntry.sample
}
