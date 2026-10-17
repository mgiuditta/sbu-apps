import SbuKit
import SwiftUI

/// One habit on the watch, as a row of the iPhone's list: the checkbox and the title after a heart
/// when Salute marks it or ⊘ for an Abitudine da evitare, then today's times and the length of an
/// Abitudine a tempo.
///
/// Ticking the box adds one time, unticking it takes today's last mark back, so a habit done more
/// times a day ticks once all are done. An Abitudine da evitare has no checkbox: its row mark fills
/// over the Limite, and a tap is one more time given in. An Abitudine a tempo is marked done with
/// a tap: its countdown runs on the iPhone.
struct WatchHabitCell: View {
    let habit: Habit
    let progress: HabitProgress
    let streak: Int
    let mark: () -> Void
    let undo: () -> Void

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

    private var isChecked: Binding<Bool> {
        Binding {
            progress.holdUndoes
        } set: { isOn in
            isOn ? mark() : undo()
        }
    }

    var body: some View {
        Group {
            if progress.limit == nil {
                Toggle(isOn: isChecked) {
                    label
                }
                .toggleStyle(SbuCheckboxStyle())
                .accessibilityValue(accessibilityValue)
            } else {
                Button(action: mark) {
                    HStack(spacing: SbuTheme.space2) {
                        SbuRowMark(filled: progress.isOverLimit)
                            .frame(width: SbuTheme.checkbox)
                        label
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(habit.title)
                .accessibilityValue(accessibilityValue)
                .accessibilityAddTraits(.isButton)
                .accessibilityActions {
                    if progress.marksToday > 0 {
                        Button("Annulla ultima", action: undo)
                    }
                }
            }
        }
        .sbuHaptic(.tick, trigger: progress.done)
    }

    private var label: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: SbuTheme.space1) {
                if let symbol = HabitKindMark.symbol(of: habit) {
                    Image(systemName: symbol)
                        .imageScale(.small)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .accessibilityHidden(true)
                }
                Text(habit.title)
                    .foregroundStyle(SbuTheme.ink)
            }
            .font(SbuTheme.footnote)
            .lineLimit(2)

            if let detail {
                detail
                    .font(SbuTheme.footnote)
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
        }
    }

    /// Today's times against the goal, or the length of an Abitudine a tempo.
    private var detail: Text? {
        if let duration = habit.timerDuration {
            Text(duration, format: TimerFormat.length)
        } else if progress.goal > 1 || progress.limit != nil {
            Text("\(progress.done) di \(progress.goal)")
        } else {
            nil
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
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: today)
        reading.log[today] = 1
        let coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today)
        return VStack(alignment: .leading, spacing: SbuTheme.space3) {
            WatchHabitCell(habit: water, progress: HabitProgress(of: water, today: today, firstWeekday: 2), streak: 4, mark: {}, undo: {})
            WatchHabitCell(habit: reading, progress: HabitProgress(of: reading, today: today, firstWeekday: 2), streak: 2, mark: {}, undo: {})
            WatchHabitCell(habit: coffee, progress: HabitProgress(of: coffee, today: today, firstWeekday: 2), streak: 1, mark: {}, undo: {})
        }
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
    }
}
