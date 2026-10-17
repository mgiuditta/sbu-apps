import SbuKit
import SwiftUI

/// One habit of today on the tool screen: the checkbox with the title, the counters in IBM Plex
/// Mono ("2 di 3 · 12 gg"), and at the trailing edge the small controls the habit needs and its
/// menu.
///
/// Ticking the box marks every time left today, unticking it takes the last one back. A habit
/// done more times a day adds one time with its plus; an Abitudine a tempo starts its Timer with
/// play. An Abitudine da evitare has no checkbox: its row mark fills over the Limite, with the
/// words, and its plus is one more time given in.
struct HabitRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let habit: Habit
    let progress: HabitProgress
    let check: HabitCheck
    let streak: Int
    /// Today has a Nota del giorno.
    var hasNote = false
    /// Ticks the box: every time left today.
    let fill: () -> Void
    /// One time more, or for an Abitudine da evitare, one more time given in.
    let markDone: () -> Void
    let undoLast: () -> Void
    let toggleSkip: () -> Void
    let edit: () -> Void
    /// Opens today's Nota del giorno.
    var writeNote: () -> Void = {}
    /// Opens the Timer of an Abitudine a tempo.
    var startTimer: () -> Void = {}

    private var face: HabitRingFace {
        HabitRingFace(habit: habit, progress: progress)
    }

    private var skipTitle: LocalizedStringKey {
        progress.isSkippedToday ? "Annulla il salto di oggi" : "Salta oggi"
    }

    private var noteTitle: LocalizedStringKey {
        hasNote ? "Modifica nota" : "Scrivi nota"
    }

    /// Play only while the timed habit still asks for something today.
    private var showsPlay: Bool {
        habit.timerDuration != nil && progress.isStillToDo && progress.isSkippedToday == false
    }

    /// One more time: a habit done more times a day not done yet, or an Abitudine da evitare.
    private var showsPlus: Bool {
        check.hasCheckbox ? check.countsTimes && check.isChecked == false : true
    }

    private var isChecked: Binding<Bool> {
        Binding {
            check.isChecked
        } set: { isOn in
            isOn ? fill() : undoLast()
        }
    }

    /// Today's state, the length of an Abitudine a tempo, the Serie, then whether today has a note
    /// and whether Salute marks it: the symbols say it on screen.
    private var accessibilityValue: Text {
        var value = face.progressText + Text(verbatim: ", ")
        if let duration = habit.timerDuration {
            value = value + Text(duration, format: TimerFormat.spoken) + Text(verbatim: ", ")
        }
        value = value + Text(habit.schedule.streakText(streak))
        if hasNote {
            value = value + Text(verbatim: ", ") + Text("con nota")
        }
        if habit.health != nil {
            value = value + Text(verbatim: ", ") + Text("collegata a Salute")
        }
        return value
    }

    var body: some View {
        Group {
            // On one line at the default text size and below; larger, the counters and then the
            // controls go under the title, so nothing is pushed past the screen's edge.
            if dynamicTypeSize > .large {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    mark
                    counters
                    controls
                }
            } else {
                HStack(spacing: SbuTheme.space3) {
                    mark
                    counters
                        .fixedSize()
                    controls
                }
            }
        }
        .sbuAffectsFigure(progress.done)
    }

    /// The checkbox with the title, or for an Abitudine da evitare the row mark with it.
    @ViewBuilder
    private var mark: some View {
        if check.hasCheckbox {
            Toggle(isOn: isChecked) {
                title
            }
            .toggleStyle(SbuCheckboxStyle())
            .accessibilityValue(accessibilityValue)
        } else {
            avoided
        }
    }

    private var controls: some View {
        HStack(spacing: SbuTheme.space3) {
            if showsPlay {
                Button(action: startTimer) {
                    Label {
                        Text("Avvia \(habit.title)")
                    } icon: {
                        Image(systemName: "play.fill")
                    }
                }
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm, isProminent: true))
            }
            if showsPlus {
                Button(action: markDone) {
                    Label {
                        Text(check.hasCheckbox ? "Aggiungi una volta a \(habit.title)" : "Segna che hai ceduto a \(habit.title)")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
                .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm))
            }
            menu
        }
        .labelStyle(.iconOnly)
    }

    /// The title after its kind's symbol, a heart when Salute marks it or ⊘ for an Abitudine da
    /// evitare, then a note symbol when today has a Nota del giorno.
    private var title: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space1) {
            if let symbol = HabitKindMark.symbol(of: habit) {
                Image(systemName: symbol)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
            Text(habit.title)
                .foregroundStyle(progress.isSkippedToday ? SbuTheme.inkMuted : SbuTheme.ink)
            if hasNote {
                Image(systemName: "note.text")
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
        }
        .fontWeight(.medium)
        .imageScale(.medium)
    }

    /// An Abitudine da evitare: the row mark in the checkbox's place, filled once over the Limite.
    private var avoided: some View {
        HStack(spacing: SbuTheme.space3) {
            SbuRowMark(filled: progress.isOverLimit)
                .frame(width: SbuTheme.checkbox)
            title
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(habit.title)
        .accessibilityValue(accessibilityValue)
    }

    /// The counters, in the metadata face: the length of an Abitudine a tempo, today's times
    /// against the goal, the words over the Limite, the Serie. VoiceOver reads them in the value.
    private var counters: some View {
        var text = Text(verbatim: "")
        var parts: [Text] = []
        if let duration = habit.timerDuration {
            parts.append(Text(duration, format: TimerFormat.length))
        }
        if progress.isSkippedToday {
            parts.append(Text("saltata"))
        } else if progress.isOverLimit {
            parts.append(Text("oltre il limite"))
        } else if progress.goal > 1 || progress.limit != nil {
            parts.append(Text("\(progress.done) di \(progress.goal)"))
        }
        parts.append(Text(habit.schedule.shortStreakText(streak)))
        for (index, part) in parts.enumerated() {
            text = text + (index == 0 ? part : Text(verbatim: " · ") + part)
        }
        return text
            .font(.sbuCartiglio)
            .monospacedDigit()
            .foregroundStyle(SbuTheme.inkMuted)
            .accessibilityHidden(true)
    }

    private var menu: some View {
        Menu {
            Button("Annulla l'ultimo segno", action: undoLast)
                .disabled(progress.marksToday == 0)
            Button(skipTitle, action: toggleSkip)
            Button(noteTitle, action: writeNote)
            Button("Modifica", action: edit)
        } label: {
            Label {
                Text("Opzioni di \(habit.title)")
            } icon: {
                Image(systemName: "ellipsis")
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.ink)
                    .frame(width: SbuTheme.controlRoundSm, height: SbuTheme.controlRoundSm)
                    .contentShape(.rect)
            }
        }
    }
}

#Preview("Light") {
    HabitRowPreview()
}

#Preview("Dark") {
    HabitRowPreview()
        .preferredColorScheme(.dark)
}

#Preview("AX5") {
    HabitRowPreview()
        .dynamicTypeSize(.accessibility5)
}

private struct HabitRowPreview: View {
    private struct Item: Identifiable {
        let habit: Habit
        let marks: Int
        let streak: Int
        var id: UUID { habit.id }
    }

    private var items: [Item] {
        let today = LogicalDay(.now)
        var timed = Habit(title: "Meditare", symbol: "brain.head.profile", createdOn: today)
        _ = timed.update(title: timed.title, symbol: timed.symbol, timesPerDay: 1, schedule: .everyDay, timerMinutes: 10, from: today)
        return [
            Item(habit: Habit(title: "Leggere", symbol: "book", createdOn: today), marks: 1, streak: 12),
            Item(habit: Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: today), marks: 3, streak: 1),
            Item(habit: timed, marks: 0, streak: 3),
            Item(habit: Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today), marks: 3, streak: 0),
        ]
    }

    var body: some View {
        SbuListCard(items) { item in
            let today = LogicalDay(.now)
            var marked = item.habit
            marked.log[today] = item.marks
            let progress = HabitProgress(of: marked, today: today, firstWeekday: 2)
            return HabitRow(
                habit: marked,
                progress: progress,
                check: HabitCheck(habit: marked, progress: progress, today: today),
                streak: item.streak,
                hasNote: item.streak == 12,
                fill: {}, markDone: {}, undoLast: {}, toggleSkip: {}, edit: {}
            )
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .tint(SbuTheme.ink)
    }
}
