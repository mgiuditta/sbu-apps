import SbuKit
import SwiftUI

/// One habit on the tool screen, as Streaks draws it: symbol in a ring with the Serie under it,
/// the title in uppercase after a heart when linked to Salute or ⊘ for an Abitudine da evitare;
/// an Abitudine a tempo also shows its length, and a play button on the ring that starts its Timer.
///
/// Hold it to add one time, hold it again once done today to take one back. A short tap opens
/// its menu. A weekly habit's ring shows the week: one segment per day done. An Abitudine da
/// evitare's ring shows the margin left; every hold is one more time given in, and over the
/// Limite the ring turns full with a cross.
struct HabitCell: View {
    /// How long to hold before the habit counts as done.
    private static let holdDuration = 0.5
    /// Where the Serie sits in the ring, as a fraction of its side from the top: under the symbol.
    private static let streakPosition = 0.75

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let habit: Habit
    let progress: HabitProgress
    let streak: Int
    /// Today has a Nota del giorno.
    var hasNote = false
    /// The ring's largest side: `.infinity` on a page of the grid, where the place sets it.
    var maxRingSide = CGFloat.infinity
    /// The captions of the cell's row in the grid, so the rings of a row stay even.
    var rowCaptions: [SlotCaption] = []
    let markDone: () -> Void
    let undoLast: () -> Void
    let toggleSkip: () -> Void
    let edit: () -> Void
    /// Opens today's Nota del giorno.
    var writeNote: () -> Void = {}
    /// Opens the Timer of an Abitudine a tempo.
    var startTimer: () -> Void = {}

    @State private var isHolding = false
    @State private var isShowingMenu = false

    /// The ring's symbol, fill and VoiceOver state, the same the widgets draw.
    private var face: HabitRingFace {
        HabitRingFace(habit: habit, progress: progress)
    }

    private var skipTitle: LocalizedStringKey {
        progress.isSkippedToday ? "Non saltare oggi" : "Salta oggi"
    }

    private var noteTitle: LocalizedStringKey {
        hasNote ? "Modifica nota" : "Scrivi nota"
    }

    private var streakText: Text {
        Text(habit.schedule.streakText(streak))
    }

    /// Today's state, the length of an Abitudine a tempo, the Serie, then whether today has a note
    /// and whether Salute marks it: the heart says it on screen.
    private var accessibilityValue: Text {
        var value = face.progressText + Text(verbatim: ", ")
        if let duration = habit.timerDuration {
            value = value + Text(duration, format: TimerFormat.spoken) + Text(verbatim: ", ")
        }
        value = value + streakText
        if hasNote {
            value = value + Text(verbatim: ", ") + Text("con nota")
        }
        if habit.health != nil {
            value = value + Text(verbatim: ", ") + Text("collegata a Salute")
        }
        return value
    }

    /// The title after its kind's symbol, a heart when Salute marks it or ⊘ for an Abitudine da
    /// evitare, then a small note symbol when today has a Nota del giorno; under it, the length of
    /// an Abitudine a tempo.
    static func caption(of habit: Habit, hasNote: Bool) -> SlotCaption {
        SlotCaption(
            title: Text(habit.title),
            kindSymbol: kindSymbol(of: habit),
            hasNote: hasNote,
            detail: habit.timerDuration.map { Text($0, format: TimerFormat.length) }
        )
    }

    private static func kindSymbol(of habit: Habit) -> String? {
        if habit.health != nil {
            "heart.fill"
        } else if habit.limit != nil {
            "nosign"
        } else {
            nil
        }
    }

    /// Play only while the timed habit still asks for something today.
    private var showsPlay: Bool {
        habit.timerDuration != nil && progress.isStillToDo && progress.isSkippedToday == false
    }

    var body: some View {
        cell
            // Outside the cell's single VoiceOver element: play is its own button.
            .overlayPreferenceValue(RingBoundsKey.self) { anchor in
                if let anchor, showsPlay {
                    GeometryReader { proxy in
                        let ring = proxy[anchor]
                        // On the ring's stroke, at the bottom right, as Streaks does.
                        let offset = ring.width / 2 * (0.5).squareRoot()
                        Button(action: startTimer) {
                            Label {
                                Text("Avvia \(habit.title)")
                            } icon: {
                                Image(systemName: "play.fill")
                            }
                        }
                        .labelStyle(.iconOnly)
                            .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRoundSm, isProminent: true))
                            .position(x: ring.midX + offset, y: ring.midY + offset)
                    }
                }
            }
    }

    private var cell: some View {
        RingSlot(maxRingSide: maxRingSide, caption: Self.caption(of: habit, hasNote: hasNote), rowCaptions: rowCaptions) {
            HabitRing(face: face, isHolding: isHolding)
                .animation(isHolding ? .linear(duration: Self.holdDuration) : .default, value: isHolding)
                .overlay {
                    // The Serie alone, no unit, inside the ring as in Streaks: "giorni" belongs to
                    // the figure, and weeks read in VoiceOver. Hidden at zero.
                    GeometryReader { proxy in
                        Text(streak, format: .number)
                            .font(SbuTheme.footnote)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .foregroundStyle(SbuTheme.inkMuted)
                            .contentTransition(.numericText(value: Double(streak)))
                            .opacity(streak > 0 ? 1 : 0)
                            .animation(reduceMotion ? nil : .snappy, value: streak)
                            .position(x: proxy.size.width / 2, y: proxy.size.height * Self.streakPosition)
                    }
                    .accessibilityHidden(true)
                }
        }
        .contentShape(.rect)
        // A dialog on tap, not a context menu: a context menu would take the long press.
        .onTapGesture(perform: showMenu)
        .onLongPressGesture(minimumDuration: Self.holdDuration, perform: toggle, onPressingChanged: setHolding)
        .sensoryFeedback(trigger: progress.done) { old, new in
            if progress.limit != nil {
                return new > progress.goal ? .warning : .impact(weight: new > old ? .medium : .light)
            }
            return new >= progress.goal ? .success : .impact(weight: new > old ? .medium : .light)
        }
        .confirmationDialog(habit.title, isPresented: $isShowingMenu, titleVisibility: .visible) {
            Button("Annulla ultima", action: undoLast)
                .disabled(progress.marksToday == 0)
            Button(skipTitle, action: toggleSkip)
            Button(noteTitle, action: writeNote)
            Button("Modifica", action: edit)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(habit.title)
        .accessibilityValue(accessibilityValue)
        .accessibilityActions {
            if progress.limit != nil {
                Button("Ho ceduto", action: markDone)
            } else if progress.holdUndoes == false {
                Button("Segna come fatta", action: markDone)
            }
            if progress.marksToday > 0 {
                Button("Annulla ultima", action: undoLast)
            }
            Button(skipTitle, action: toggleSkip)
            Button(noteTitle, action: writeNote)
            Button("Modifica", action: edit)
        }
    }

    private func toggle() {
        // The finger may still be down: stop counting it as a hold, or the ring would flip back.
        isHolding = false
        progress.holdUndoes ? undoLast() : markDone()
    }

    private func showMenu() {
        isShowingMenu = true
    }

    private func setHolding(_ isPressing: Bool) {
        isHolding = isPressing
    }
}

#Preview("Light") {
    HabitCellPreview()
}

#Preview("Dark") {
    HabitCellPreview()
        .preferredColorScheme(.dark)
}

private struct HabitCellPreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            HabitCellPreviewItem(habit: Habit(title: "Leggere", symbol: "book", createdOn: LogicalDay(.now)), marks: 1, streak: 12, hasNote: true)
            HabitCellPreviewItem(habit: Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: LogicalDay(.now)), marks: 3, streak: 1)
            HabitCellPreviewItem(habit: Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: LogicalDay(.now)), marks: 1, streak: 4)
            HabitCellPreviewItem(habit: .timedPreview, marks: 0, streak: 3)
            HabitCellPreviewItem(habit: Habit(title: "Non fumare", symbol: "lungs", limit: 0, createdOn: LogicalDay(.now)), marks: 1, streak: 0)
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}

private extension Habit {
    static var timedPreview: Habit {
        var habit = Habit(title: "Meditare", symbol: "brain.head.profile", createdOn: LogicalDay(.now))
        _ = habit.update(title: habit.title, symbol: habit.symbol, timesPerDay: 1, schedule: .everyDay, timerMinutes: 10, from: LogicalDay(.now))
        return habit
    }
}

private struct HabitCellPreviewItem: View {
    let habit: Habit
    let marks: Int
    let streak: Int
    var hasNote = false

    var body: some View {
        var marked = habit
        marked.log[LogicalDay(.now)] = marks
        return HabitCell(habit: marked, progress: HabitProgress(of: marked, today: LogicalDay(.now), firstWeekday: 2), streak: streak, hasNote: hasNote, markDone: {}, undoLast: {}, toggleSkip: {}, edit: {})
    }
}
