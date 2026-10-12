import SbuKit
import SwiftUI

/// One habit on the tool screen: symbol in a ring, title, Serie.
///
/// Hold it to add one time, hold it again once done today to take one back. A short tap opens
/// its menu. A weekly habit's ring shows the week: one segment per day done. An Abitudine da
/// evitare's ring shows the margin left; every hold is one more time given in, and over the
/// Limite the ring turns full with a cross.
struct HabitCell: View {
    /// How long to hold before the habit counts as done.
    private static let holdDuration = 0.5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let habit: Habit
    let progress: HabitProgress
    let streak: Int
    let markDone: () -> Void
    let undoLast: () -> Void
    let toggleSkip: () -> Void
    let edit: () -> Void

    @State private var isHolding = false
    @State private var isShowingMenu = false

    @ScaledMetric(relativeTo: .title2) private var ringSize = SbuTheme.space12 * 2

    /// Filled segments, moving one segment forward while holding, or back when the hold undoes
    /// or uses up the margin.
    private var filled: Double {
        if progress.limit != nil {
            if progress.isOverLimit { return Double(max(progress.goal, 1)) }
            return Double(isHolding ? max(progress.margin - 1, 0) : progress.margin)
        }
        guard isHolding else { return Double(progress.done) }
        return Double(progress.holdUndoes ? progress.done - 1 : progress.done + 1)
    }

    /// The symbol in the ring: a checkmark when done, a skip mark when skipped, so state never rests on color.
    private var symbol: String {
        if progress.isSkippedToday && habit.schedule.isWeekly == false {
            "forward"
        } else if progress.isOverLimit {
            "xmark"
        } else if progress.limit != nil {
            habit.symbol
        } else if progress.isComplete {
            "checkmark"
        } else {
            habit.symbol
        }
    }

    private var skipTitle: LocalizedStringKey {
        progress.isSkippedToday ? "Non saltare oggi" : "Salta oggi"
    }

    private var progressText: Text {
        if progress.isSkippedToday {
            Text("Saltata oggi")
        } else if progress.isOverLimit {
            Text("Da evitare, limite superato, \(progress.done) su \(progress.goal)")
        } else if progress.limit != nil {
            Text("Da evitare, \(progress.done) su \(progress.goal)")
        } else if progress.goal > 1 {
            Text("\(progress.done) di \(progress.goal)")
        } else {
            Text(progress.isComplete ? "Fatta" : "Da fare")
        }
    }

    private var streakText: Text {
        habit.schedule.isWeekly ? Text("\(streak) settimane") : Text("\(streak) giorni")
    }

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            HabitRing(symbol: symbol, segments: max(progress.goal, 1), filled: filled)
                // Over the Limite, with the cross: never color alone.
                .tint(progress.isOverLimit ? SbuTheme.danger : nil)
                // Up to its scaled size, never wider than the column.
                .frame(maxWidth: ringSize, maxHeight: ringSize)
                .aspectRatio(1, contentMode: .fit)
                .animation(isHolding ? .linear(duration: Self.holdDuration) : .default, value: isHolding)

            Text(habit.title)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // The Serie alone, no unit: "giorni" belongs to the figure, and weeks read in VoiceOver. Hidden at zero, kept for even rows.
            Text(streak, format: .number)
                .font(SbuTheme.footnote)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
                .contentTransition(.numericText(value: Double(streak)))
                .opacity(streak > 0 ? 1 : 0)
                .animation(reduceMotion ? nil : .snappy, value: streak)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
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
            Button("Modifica", action: edit)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(habit.title)
        .accessibilityValue(progressText + Text(verbatim: ", ") + streakText)
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
            HabitCellPreviewItem(habit: Habit(title: "Leggere", symbol: "book", createdOn: LogicalDay(.now)), marks: 1, streak: 12)
            HabitCellPreviewItem(habit: Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: LogicalDay(.now)), marks: 3, streak: 1)
            HabitCellPreviewItem(habit: Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: LogicalDay(.now)), marks: 1, streak: 4)
            HabitCellPreviewItem(habit: Habit(title: "Non fumare", symbol: "lungs", limit: 0, createdOn: LogicalDay(.now)), marks: 1, streak: 0)
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}

private struct HabitCellPreviewItem: View {
    let habit: Habit
    let marks: Int
    let streak: Int

    var body: some View {
        var marked = habit
        marked.log[LogicalDay(.now)] = marks
        return HabitCell(habit: marked, progress: HabitProgress(of: marked, today: LogicalDay(.now), firstWeekday: 2), streak: streak, markDone: {}, undoLast: {}, toggleSkip: {}, edit: {})
    }
}
