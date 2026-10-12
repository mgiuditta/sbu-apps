import SbuKit
import SwiftUI

/// One habit on the field: symbol in a ring, title, Serie.
///
/// Hold it to add one time, hold it again once done today to take one back. A short tap opens
/// its menu. A weekly habit's ring shows the week: one segment per day done.
struct HabitCell: View {
    /// How long to hold before the habit counts as done.
    private static let holdDuration = 0.5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let habit: Habit
    let progress: HabitProgress
    let streak: Int
    let markDone: () -> Void
    let undoLast: () -> Void

    @State private var isHolding = false
    @State private var isShowingMenu = false

    @ScaledMetric(relativeTo: .title2) private var ringSize = SbuTheme.space12 * 2

    /// Filled segments, moving one segment forward while holding, or back when the hold undoes.
    private var filled: Double {
        guard isHolding else { return Double(progress.done) }
        return Double(progress.holdUndoes ? progress.done - 1 : progress.done + 1)
    }

    private var progressText: Text {
        if progress.goal > 1 {
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
            HabitRing(symbol: progress.isComplete ? "checkmark" : habit.symbol, segments: progress.goal, filled: filled)
                // Up to its scaled size, never wider than the column.
                .frame(maxWidth: ringSize, maxHeight: ringSize)
                .aspectRatio(1, contentMode: .fit)
                .animation(isHolding ? .linear(duration: Self.holdDuration) : .default, value: isHolding)

            Text(habit.title)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.onField)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // The Serie alone, no unit: "giorni" belongs to the figure, and weeks read in VoiceOver. Hidden at zero, kept for even rows.
            Text(streak, format: .number)
                .font(SbuTheme.footnote)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.onFieldMuted)
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
            new >= progress.goal ? .success : .impact(weight: new > old ? .medium : .light)
        }
        .confirmationDialog(habit.title, isPresented: $isShowingMenu, titleVisibility: .visible) {
            Button("Annulla ultima", action: undoLast)
                .disabled(progress.marksToday == 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(habit.title)
        .accessibilityValue(progressText + Text(verbatim: ", ") + streakText)
        .accessibilityActions {
            if progress.holdUndoes == false {
                Button("Segna come fatta", action: markDone)
            }
            if progress.marksToday > 0 {
                Button("Annulla ultima", action: undoLast)
            }
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
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
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
        return HabitCell(habit: marked, progress: HabitProgress(of: marked, today: LogicalDay(.now), firstWeekday: 2), streak: streak, markDone: {}, undoLast: {})
    }
}
