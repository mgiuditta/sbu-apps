import SbuKit
import SwiftUI

/// One habit on the field: symbol in a ring, title, Serie. Hold it to mark it done.
struct HabitCell: View {
    /// How long to hold before the habit counts as done.
    private static let holdDuration = 0.5

    let habit: Habit
    let streak: Int
    let isDone: Bool
    let markDone: () -> Void
    let undoLast: () -> Void

    @State private var isHolding = false

    @ScaledMetric(relativeTo: .title2) private var ringSize = SbuTheme.space12 * 2

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            HabitRing(symbol: isDone ? "checkmark" : habit.symbol, progress: isDone || isHolding ? 1 : 0)
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
                .opacity(streak > 0 ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .onLongPressGesture(minimumDuration: Self.holdDuration, perform: markDone, onPressingChanged: setHolding)
        .sensoryFeedback(.success, trigger: isDone) { wasDone, isDone in !wasDone && isDone }
        .contextMenu {
            Button("Annulla ultima", systemImage: "arrow.uturn.backward", action: undoLast)
                .disabled(isDone == false)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(habit.title)
        .accessibilityValue(Text(isDone ? "Fatta" : "Da fare") + Text(verbatim: ", ") + Text("\(streak) giorni"))
        .accessibilityActions {
            if isDone {
                Button("Annulla ultima", action: undoLast)
            } else {
                Button("Segna come fatta", action: markDone)
            }
        }
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
            HabitCell(habit: Habit(title: "Leggere", symbol: "book", createdOn: LogicalDay(.now)), streak: 12, isDone: true, markDone: {}, undoLast: {})
            HabitCell(habit: Habit(title: "Camminare", symbol: "figure.walk", createdOn: LogicalDay(.now)), streak: 1, isDone: false, markDone: {}, undoLast: {})
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.fieldHabits)
        .environment(\.colorScheme, .dark)
        .tint(SbuTheme.accentHabits)
    }
}
