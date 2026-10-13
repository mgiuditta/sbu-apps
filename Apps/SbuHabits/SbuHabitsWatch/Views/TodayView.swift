import SbuKit
import SwiftUI

/// The watch's one screen: the Serie piena on top, today's habits in two columns under it, one at
/// accessibility text sizes. On `surface`, warm black on the watch, like every screen.
struct TodayView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let habits: WatchHabits

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: SbuTheme.space2, alignment: .top), count: dynamicTypeSize.isAccessibilitySize ? 1 : 2)
    }

    var body: some View {
        Group {
            if let snapshot = habits.shown {
                // Redrawn when the day the grid belongs to ends.
                TimelineView(.explicit([snapshot.nextDayStart])) { context in
                    if snapshot.isCurrent(at: context.date) {
                        grid(snapshot)
                    } else {
                        ContentUnavailableView("Nuovo giorno", systemImage: "iphone", description: Text("Apri Sbu Habits sull'iPhone per le abitudini di oggi."))
                    }
                }
            } else {
                ContentUnavailableView("Nessuna abitudine", systemImage: "iphone", description: Text("Apri Sbu Habits sull'iPhone per vedere qui le tue abitudini."))
            }
        }
        .background(SbuTheme.surface)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, let snapshot = habits.shown, snapshot.isCurrent(at: .now) == false {
                habits.requestRefresh()
            }
        }
    }

    private func grid(_ snapshot: WatchSnapshot) -> some View {
        let done = snapshot.habits.count { snapshot.progress(of: $0).isComplete }
        return ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space3) {
                WatchFigure(value: snapshot.fullStreak, context: context(done: done, total: snapshot.habits.count))

                LazyVGrid(columns: columns, spacing: SbuTheme.space3) {
                    ForEach(snapshot.habits) { habit in
                        WatchHabitCell(
                            habit: habit,
                            progress: snapshot.progress(of: habit),
                            streak: snapshot.streaks[habit.id] ?? 0,
                            mark: { habits.mark(habit) },
                            undo: { habits.undo(habit) }
                        )
                    }
                }
            }
            .padding(.horizontal, SbuTheme.space1)
        }
        .animation(reduceMotion ? nil : .snappy, value: snapshot.fullStreak)
    }

    private func context(done: Int, total: Int) -> Text {
        if total == 0 {
            Text("Niente previsto oggi")
        } else {
            Text("\(done) su \(total) oggi")
        }
    }
}

#Preview("Light") {
    TodayView(habits: .demo())
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    TodayView(habits: .demo())
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
