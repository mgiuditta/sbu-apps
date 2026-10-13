import SbuKit
import SwiftUI

/// One habit on the watch: its ring, as the iPhone and the widgets draw it, and the title under
/// it after a heart when Salute marks it or ⊘ for an Abitudine da evitare; an Abitudine a tempo
/// also shows its length.
///
/// A tap adds one time, as a hold does on the iPhone; for an Abitudine da evitare, one more time
/// given in. A long press takes today's last mark back. An Abitudine a tempo is marked done with
/// a tap: its countdown runs on the iPhone.
struct WatchHabitCell: View {
    /// How long to press before today's last mark goes back.
    private static let pressDuration = 0.5

    let habit: Habit
    let progress: HabitProgress
    let streak: Int
    let mark: () -> Void
    let undo: () -> Void

    @ScaledMetric(relativeTo: .body) private var ringSide = SbuTheme.controlRound

    private var face: HabitRingFace {
        HabitRingFace(habit: habit, progress: progress)
    }

    /// Today's state, the length of an Abitudine a tempo, the Serie, then whether Salute marks it.
    private var accessibilityValue: Text {
        var value = face.progressText + Text(verbatim: ", ")
        if let duration = habit.timerDuration {
            value = value + Text(duration, format: TimerFormat.spoken) + Text(verbatim: ", ")
        }
        value = value + Text(habit.schedule.streakText(streak))
        if habit.health != nil {
            value = value + Text(verbatim: ", ") + Text("collegata a Salute")
        }
        return value
    }

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            HabitRing(face: face, symbolFont: SbuTheme.headline, lineWidth: SbuTheme.space1)
                .frame(width: ringSide, height: ringSide)

            HStack(spacing: SbuTheme.space1) {
                if let symbol = HabitKindMark.symbol(of: habit) {
                    Image(systemName: symbol)
                        .imageScale(.small)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                Text(habit.title)
                    .foregroundStyle(SbuTheme.ink)
            }
            .font(SbuTheme.footnote)
            .lineLimit(2)
            .multilineTextAlignment(.center)

            if let duration = habit.timerDuration {
                Text(duration, format: TimerFormat.length)
                    .font(SbuTheme.footnote)
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .onTapGesture(perform: mark)
        .onLongPressGesture(minimumDuration: Self.pressDuration, perform: undo)
        .sensoryFeedback(trigger: progress.done) { old, new in
            if progress.limit != nil {
                return new > progress.goal ? .warning : .impact(weight: new > old ? .medium : .light)
            }
            return new >= progress.goal ? .success : .impact(weight: new > old ? .medium : .light)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(habit.title)
        .accessibilityValue(accessibilityValue)
        .accessibilityAction(named: progress.limit != nil ? Text("Ho ceduto") : Text("Segna come fatta"), mark)
        .accessibilityActions {
            if progress.marksToday > 0 {
                Button("Annulla ultima", action: undo)
            }
        }
    }
}

#Preview("Light") {
    WatchHabitCellPreview()
}

#Preview("Dark") {
    WatchHabitCellPreview()
        .preferredColorScheme(.dark)
}

private struct WatchHabitCellPreview: View {
    var body: some View {
        let today = LogicalDay(.now)
        var water = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: today)
        water.log[today] = 3
        let coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today)
        return HStack(alignment: .top) {
            WatchHabitCell(habit: water, progress: HabitProgress(of: water, today: today, firstWeekday: 2), streak: 4, mark: {}, undo: {})
            WatchHabitCell(habit: coffee, progress: HabitProgress(of: coffee, today: today, firstWeekday: 2), streak: 1, mark: {}, undo: {})
        }
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
