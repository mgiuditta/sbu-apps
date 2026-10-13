import SbuKit
import SwiftUI

/// The watch's one screen: the Serie piena on top, today's habits in two columns under it, one at
/// accessibility text sizes. On `surface`, warm black on the watch, like every screen.
struct TodayView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let habits: WatchHabits

    /// The moment the grid is checked against: now, then the end of the grid's day.
    @State private var now = Date.now

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: SbuTheme.space2, alignment: .top), count: dynamicTypeSize.isAccessibilitySize ? 1 : 2)
    }

    var body: some View {
        Group {
            if let snapshot = habits.shown {
                if snapshot.isCurrent(at: now) {
                    grid(snapshot)
                } else {
                    ContentUnavailableView("Nuovo giorno", systemImage: "iphone", description: Text("Apri Sbu Habits sull'iPhone per le abitudini di oggi."))
                }
            } else {
                ContentUnavailableView("Nessuna abitudine", systemImage: "iphone", description: Text("Apri Sbu Habits sull'iPhone per vedere qui le tue abitudini."))
            }
        }
        .background(SbuTheme.surface)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            now = .now
            if let snapshot = habits.shown, snapshot.isCurrent(at: now) == false {
                habits.requestRefresh()
            }
        }
        // Leaves the grid when its day ends, while the app stays open.
        .task(id: habits.shown?.nextDayStart) {
            now = .now
            guard let end = habits.shown?.nextDayStart else { return }
            try? await Task.sleep(for: .seconds(max(end.timeIntervalSinceNow, 1)))
            if Task.isCancelled == false {
                now = .now
                habits.requestRefresh()
            }
        }
    }

    private func grid(_ snapshot: WatchSnapshot) -> some View {
        let tally = TodayTally(snapshot)
        return ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space3) {
                WatchFigure(value: tally.fullStreak, context: context(tally))

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

    private func context(_ tally: TodayTally) -> Text {
        if tally.total == 0 {
            Text("Niente previsto oggi")
        } else {
            Text("\(tally.done) su \(tally.total) oggi")
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
