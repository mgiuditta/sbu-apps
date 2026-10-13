import SbuKit
import SwiftUI
import WidgetKit

/// One habit's ring as Streaks draws it, big enough to tap: the Serie inside under the symbol,
/// the title in uppercase under the ring.
struct SingleHabitWidgetView: View {
    let entry: SingleHabitEntry

    var body: some View {
        Group {
            if let habit = entry.habit, let progress = entry.progress {
                WidgetRingButton(habit: habit, progress: progress, streak: entry.streak, showsCaption: true, isAlone: true)
            } else {
                WidgetEmptyText()
            }
        }
        .tint(SbuTheme.accentHabits)
        .containerBackground(for: .widget) {
            SbuTheme.surface
        }
    }
}

// The canvas switches light, dark and tinted; the shared views have their own previews.
#Preview("Small", as: .systemSmall) {
    SingleHabitWidget()
} timeline: {
    SingleHabitEntry.sample
    SingleHabitEntry.overLimitSample
}
