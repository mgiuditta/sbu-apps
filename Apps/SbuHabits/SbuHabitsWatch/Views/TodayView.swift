import SbuKit
import SwiftUI

/// The watch's one screen: the Serie piena on top, today's habits in a list under it, each with
/// its checkbox. On `paper`, warm black on the watch, like every screen.
struct TodayView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let habits: WatchHabits

    /// The moment the grid is checked against: now, then the end of the grid's day.
    @State private var now = Date.now

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
        .background(SbuTheme.paper)
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
                WatchFigure(value: tally.fullStreak, fullStop: tally.isComplete && tally.fullStreak > 0 ? .set : .waiting, context: context(tally))

                VStack(alignment: .leading, spacing: SbuTheme.space3) {
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
        .animation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion), value: snapshot.fullStreak)
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
        .tint(SbuTheme.ink)
        .environment(\.sbuAccent, .habits)
}

#Preview("Dark") {
    TodayView(habits: .demo())
        .tint(SbuTheme.ink)
        .environment(\.sbuAccent, .habits)
        .preferredColorScheme(.dark)
}
