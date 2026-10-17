import SbuKit
import SwiftUI

/// A habit's ring in a widget, drawn as the home draws it: the symbol in the ring, the Serie
/// under the symbol when the ring has room for it, and the title in uppercase after the heart
/// or the ⊘. A tap marks it once with `MarkHabitIntent`; an Abitudine a tempo is marked done
/// without its Timer, as a hold on the home does.
struct WidgetRingButton: View {
    /// Where the Serie sits in the ring, as a fraction of its side from the top: under the symbol.
    private static let streakPosition = 0.75
    /// The smallest ring with room for the Serie under the symbol: the grid's rings are smaller,
    /// as in Streaks, and leave it to VoiceOver.
    private static let minStreakRingSide = SbuTheme.space12 * 2

    let habit: Habit
    let progress: HabitProgress
    let streak: Int
    let showsCaption: Bool
    /// The single habit's widget has room for the length of an Abitudine a tempo, and the larger
    /// caption; the grid's cells do not.
    var isAlone = false

    private var face: HabitRingFace {
        HabitRingFace(habit: habit, progress: progress)
    }

    private var streakText: Text {
        Text(habit.schedule.streakText(streak))
    }

    /// The same as the home's cell: today's state, the length of an Abitudine a tempo, the Serie,
    /// and Salute, which the heart says on screen.
    private var accessibilityValue: Text {
        var value = face.progressText + Text(verbatim: ", ")
        if let duration = habit.timerDuration {
            value = value + Text(duration, format: TimerFormat.spoken) + Text(verbatim: ", ")
        }
        value = value + streakText
        if habit.health != nil {
            value = value + Text(verbatim: ", ") + Text("collegata a Salute")
        }
        return value
    }

    var body: some View {
        Button(intent: MarkHabitIntent(habitID: habit.id)) {
            VStack(spacing: SbuTheme.space1) {
                HabitRing(face: face)
                    .overlay {
                        GeometryReader { proxy in
                            Text(streak, format: .number)
                                .font(SbuTheme.footnote)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                                .foregroundStyle(SbuTheme.inkMuted)
                                // Past the default size the number would cover the symbol.
                                .dynamicTypeSize(...DynamicTypeSize.large)
                                .position(x: proxy.size.width / 2, y: proxy.size.height * Self.streakPosition)
                                .opacity(streak > 0 && proxy.size.width >= Self.minStreakRingSide ? 1 : 0)
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if showsCaption {
                    SlotCaption(
                        title: Text(habit.title),
                        kindSymbol: HabitKindMark.symbol(of: habit),
                        detail: isAlone ? habit.timerDuration.map { Text($0, format: TimerFormat.length) } : nil,
                        maxLines: 1,
                        font: isAlone ? SbuTheme.footnote : SbuTheme.caption
                    )
                        .dynamicTypeSize(...DynamicTypeSize.xLarge)
                }
            }
        }
        // Not disabled, which would dim a done habit: marking it again changes nothing. An
        // Abitudine da evitare counts one more time given in on every tap.
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(habit.title)
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("Light") {
    WidgetRingButtonPreview()
}

#Preview("Dark") {
    WidgetRingButtonPreview()
        .preferredColorScheme(.dark)
}

private struct WidgetRingButtonPreview: View {
    private let today = LogicalDay(.now)

    var body: some View {
        var reading = Habit(title: "Leggere", symbol: "book", createdOn: today)
        reading.log[today] = 1
        var coffee = Habit(title: "Caffè", symbol: "cup.and.saucer", limit: 2, createdOn: today)
        coffee.log[today] = 1
        return HStack(spacing: SbuTheme.space2) {
            WidgetRingButton(habit: reading, progress: HabitProgress(of: reading, today: today, firstWeekday: 2), streak: 12, showsCaption: true, isAlone: true)
                .frame(width: 138, height: 138)
            WidgetRingButton(habit: coffee, progress: HabitProgress(of: coffee, today: today, firstWeekday: 2), streak: 3, showsCaption: true)
                .frame(width: 72, height: 72)
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
    }
}
