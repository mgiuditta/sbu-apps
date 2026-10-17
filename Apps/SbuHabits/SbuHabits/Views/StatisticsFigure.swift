import SbuKit
import SwiftUI

/// The one figure of a Statistiche page, the completion rate as `SbuFigure` closed by the full
/// stop, with the Serie migliore and the completions small under it. With nothing expected the
/// figure is a dash, and a dash is not a closed figure: it has no full stop.
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
                    // Spaced capitals: past the first accessibility size a word such as
                    // COMPLETAMENTO no longer fits a small iPhone and breaks in half.
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .foregroundStyle(SbuTheme.inkMuted)

                // The dash of a period with nothing expected stays open.
                SbuFigure(value: rate, fullStop: statistics.tally.rate != nil && showsFullStop ? .set : .absent)
                    .fixedSize(horizontal: false, vertical: true)

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
                // Spaced capitals: past the first accessibility size a word such as
                // COMPLETAMENTO no longer fits a small iPhone and breaks in half.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
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
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    StatisticsFigure(statistics: .all(model.habits, period: .all, today: model.today, firstWeekday: 2), streakSchedule: .everyDay, showsFullStop: true)
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
