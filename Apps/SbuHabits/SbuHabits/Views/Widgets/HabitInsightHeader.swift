import SbuKit
import SwiftUI

/// The top of a one-habit widget, as in Streaks: the habit's ring, small, with today's progress,
/// then its title in uppercase after the heart or the ⊘.
struct HabitInsightHeader: View {
    let habit: Habit
    let progress: HabitProgress
    let streak: Int

    @ScaledMetric(relativeTo: .footnote) private var ringSide = SbuTheme.space8

    private var face: HabitRingFace {
        HabitRingFace(habit: habit, progress: progress)
    }

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            HabitRing(face: face, symbolFont: SbuTheme.caption, lineWidth: SbuTheme.space1)
                .frame(width: ringSide, height: ringSide)

            SlotCaption(title: Text(habit.title), kindSymbol: HabitKindMark.symbol(of: habit), maxLines: 1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(habit.title)
        .accessibilityValue(face.progressText + Text(verbatim: ", ") + Text(habit.schedule.streakText(streak)))
    }
}

#Preview("Light") {
    HabitInsightHeaderPreview()
}

#Preview("Dark") {
    HabitInsightHeaderPreview()
        .preferredColorScheme(.dark)
}

private struct HabitInsightHeaderPreview: View {
    var body: some View {
        let today = LogicalDay(.now)
        var water = Habit(title: "Bere acqua", symbol: "drop", timesPerDay: 8, createdOn: today)
        water.log[today] = 3
        return HabitInsightHeader(habit: water, progress: HabitProgress(of: water, today: today, firstWeekday: 2), streak: 4)
            .frame(width: 138)
            .padding(SbuTheme.space4)
            .background(SbuTheme.paper)
            .tint(SbuTheme.ink)
    }
}
