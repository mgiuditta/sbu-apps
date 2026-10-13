import SbuKit
import SwiftUI
import WidgetKit

/// The Serie in large, as in Streaks: the widget's one figure, so it is closed by the full stop,
/// under its caption. The number keeps the hero size while it fits, then steps down to `stat`.
struct StreakInsight: View {
    let streak: Int
    /// The unit VoiceOver reads: days, or weeks or months for a counted habit.
    let schedule: Schedule

    @ScaledMetric(relativeTo: .largeTitle) private var heroSize = SbuTheme.statHeroSize
    @ScaledMetric(relativeTo: .largeTitle) private var statSize = SbuTheme.statSize

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text("Serie")
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)

            ViewThatFits(in: .horizontal) {
                figure(size: heroSize, tracking: SbuTheme.statHeroTracking)
                figure(size: statSize, tracking: SbuTheme.statTracking)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .dynamicTypeSize(...DynamicTypeSize.large)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Serie"))
        .accessibilityValue(Text(schedule.streakText(streak)))
    }

    private func figure(size: CGFloat, tracking: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(streak, format: .number)
                .font(SbuTheme.numberFont(size: size))
                .tracking(tracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, -tracking)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
                .fixedSize()

            SbuFullStop(fontSize: size)
                .widgetAccentable()
        }
    }
}

#Preview("Light") {
    StreakInsightPreview()
}

#Preview("Dark") {
    StreakInsightPreview()
        .preferredColorScheme(.dark)
}

private struct StreakInsightPreview: View {
    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            StreakInsight(streak: 12, schedule: .everyDay)
            StreakInsight(streak: 1_204, schedule: .everyDay)
        }
        .frame(width: 300, height: 100)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
