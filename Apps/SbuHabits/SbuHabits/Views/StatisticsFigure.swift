import SbuKit
import SwiftUI

/// The one figure of a Statistiche page, the completion rate in `statHero` closed by the full
/// stop, with the Serie migliore and the completions small under it.
///
/// Every page is a screen with its figure, but while a swipe is between two both show: only the
/// page on show draws its full stop, so there is never more than one.
struct StatisticsFigure: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let statistics: HabitStatistics
    /// The unit of the Serie migliore: days, or weeks or months for a counted habit.
    let streakSchedule: Schedule
    let showsFullStop: Bool

    @ScaledMetric(relativeTo: .title2) private var smallSize = SbuTheme.statSmallSize

    private var rate: String {
        // An en dash, never 0 %, when nothing was expected yet.
        statistics.tally.rate?.formatted(.percent.precision(.fractionLength(0...1))) ?? "–"
    }

    private var smallLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: SbuTheme.space3)) : AnyLayout(HStackLayout(spacing: SbuTheme.space4))
    }

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            VStack(spacing: SbuTheme.space1) {
                Text("Completamento")
                    .font(SbuTheme.caption)
                    .textCase(.uppercase)
                    .tracking(SbuTheme.captionTracking)
                    .foregroundStyle(SbuTheme.inkMuted)

                HeroRate(rate: rate, showsFullStop: showsFullStop)
                    // Past the first accessibility size "100%" would not fit across the screen.
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)

                if statistics.tally.rate == nil {
                    Text("Niente previsto in questo periodo")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)

            smallLayout {
                SmallNumber(value: Text(streakSchedule.streakText(statistics.bestStreak)), caption: "Serie migliore", size: smallSize)
                SmallNumber(value: Text(statistics.completions, format: .number), caption: "Completamenti", size: smallSize)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// The completion rate in `statHero`, closed by the full stop when its page is on show.
private struct HeroRate: View {
    let rate: String
    let showsFullStop: Bool

    @ScaledMetric(relativeTo: .largeTitle) private var size = SbuTheme.statHeroSize

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(verbatim: rate)
                .font(SbuTheme.numberFont(size: size))
                .tracking(SbuTheme.statHeroTracking)
                // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                .padding(.trailing, -SbuTheme.statHeroTracking)
                .foregroundStyle(SbuTheme.ink)
                .contentTransition(.numericText())

            SbuFullStop(fontSize: size)
                .opacity(showsFullStop ? 1 : 0)
        }
    }
}

/// A secondary number under the figure, in `inkMuted`, with its caption.
private struct SmallNumber: View {
    let value: Text
    let caption: LocalizedStringKey
    let size: CGFloat

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            value
                .font(SbuTheme.smallNumberFont(size: size))
                .foregroundStyle(SbuTheme.inkMuted)
            Text(caption)
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(caption))
        .accessibilityValue(value)
    }
}

#Preview("Light") {
    let model = HabitsModel.preview
    StatisticsFigure(statistics: .all(model.habits, period: .all, today: model.today, firstWeekday: 2), streakSchedule: .everyDay, showsFullStop: true)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    StatisticsFigure(statistics: .all(model.habits, period: .all, today: model.today, firstWeekday: 2), streakSchedule: .everyDay, showsFullStop: true)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
