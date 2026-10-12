import SbuKit
import SwiftUI
import WidgetKit

/// Today's habits as rings on paper; tapping a ring marks it once.
struct HabitsWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: HabitsWidgetEntry

    /// Columns and rows per size: 2×2 small, 4×2 medium, 4×4 large.
    private var layout: (columns: Int, rows: Int) {
        switch family {
        case .systemSmall: (2, 2)
        case .systemLarge: (4, 4)
        default: (4, 2)
        }
    }

    var body: some View {
        Group {
            if entry.habits.isEmpty {
                Text("Aggiungi un'abitudine nell'app")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .multilineTextAlignment(.center)
            } else {
                HabitsWidgetGrid(
                    slots: WidgetSlots(entry.habits, progress: entry.progress, capacity: layout.columns * layout.rows),
                    progress: entry.progress,
                    columns: layout.columns,
                    rows: layout.rows,
                    showsTitles: family != .systemSmall
                )
            }
        }
        .tint(SbuTheme.accentHabits)
        .containerBackground(for: .widget) {
            SbuTheme.surface
        }
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

#Preview("Large", as: .systemLarge) {
    HabitsWidget()
} timeline: {
    HabitsWidgetEntry.sample
}
