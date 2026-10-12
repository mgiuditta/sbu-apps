import SbuKit
import SwiftUI

/// One habit on the field: symbol in a ring, title, Serie.
///
/// Hold it to add one time, hold it again once done to take one back. A short tap opens its menu.
struct HabitCell: View {
    /// How long to hold before the habit counts as done.
    private static let holdDuration = 0.5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let habit: Habit
    /// Times done today.
    let count: Int
    let streak: Int
    let markDone: () -> Void
    let undoLast: () -> Void

    @State private var isHolding = false
    @State private var isShowingMenu = false

    @ScaledMetric(relativeTo: .title2) private var ringSize = SbuTheme.space12 * 2

    private var isDone: Bool {
        count >= habit.timesPerDay
    }

    /// Filled segments, moving one segment forward while holding, or back once done.
    private var filled: Double {
        guard isHolding else { return Double(count) }
        return Double(isDone ? count - 1 : count + 1)
    }

    private var progress: Text {
        habit.timesPerDay > 1 ? Text("\(count) di \(habit.timesPerDay)") : Text(isDone ? "Fatta" : "Da fare")
    }

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            HabitRing(symbol: isDone ? "checkmark" : habit.symbol, segments: habit.timesPerDay, filled: filled)
                .frame(width: ringSize, height: ringSize)
                .animation(isHolding ? .linear(duration: Self.holdDuration) : .default, value: isHolding)

            Text(habit.title)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.onField)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // The Serie alone, no unit: the word "giorni" belongs to the figure. Hidden at zero, kept for even rows.
            Text(streak, format: .number)
                .font(SbuTheme.footnote)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.onFieldMuted)
                .contentTransition(.numericText(value: Double(streak)))
                .opacity(streak > 0 ? 1 : 0)
                .animation(reduceMotion ? nil : .snappy, value: streak)
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        // A dialog on tap, not a context menu: a context menu would take the long press.
        .onTapGesture(perform: showMenu)
        .onLongPressGesture(minimumDuration: Self.holdDuration, perform: toggle, onPressingChanged: setHolding)
        .sensoryFeedback(trigger: count) { old, new in
            new >= habit.timesPerDay ? .success : .impact(weight: new > old ? .medium : .light)
        }
        .confirmationDialog(habit.title, isPresented: $isShowingMenu, titleVisibility: .visible) {
            Button("Annulla ultima", action: undoLast)
                .disabled(count == 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(habit.title)
        .accessibilityValue(progress + Text(verbatim: ", ") + Text("\(streak) giorni"))
        .accessibilityActions {
            if isDone == false {
                Button("Segna come fatta", action: markDone)
            }
            if count > 0 {
                Button("Annulla ultima", action: undoLast)
            }
        }
    }

    private func toggle() {
        // The finger may still be down: stop counting it as a hold, or the ring would flip back.
        isHolding = false
        isDone ? undoLast() : markDone()
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
            HabitCell(habit: Habit(title: "Leggere", symbol: "book", createdOn: LogicalDay(.now)), count: 1, streak: 12, markDone: {}, undoLast: {})
            HabitCell(habit: Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: LogicalDay(.now)), count: 3, streak: 1, markDone: {}, undoLast: {})
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
    }
}
