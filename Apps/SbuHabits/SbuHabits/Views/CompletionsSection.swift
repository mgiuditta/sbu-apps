import SbuKit
import SwiftUI

/// Completamenti on a Statistiche page: the bars by weekday next to the curve by hour, one above
/// the other at accessibility text sizes. A habit to avoid has no curve: its marks are times
/// given in. Days marked before hours were saved have none, and the curve says so. With no
/// completions in the period both charts would be empty: one box says so instead.
struct CompletionsSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let statistics: HabitStatistics
    /// The page of an Abitudine da evitare.
    let isAvoided: Bool

    @ScaledMetric(relativeTo: .body) private var height = SbuTheme.space12 * 3

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: SbuTheme.space6)) : AnyLayout(HStackLayout(alignment: .top, spacing: SbuTheme.space4))
    }

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            Text("Completamenti")
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                // Spaced capitals: past the first accessibility size a word such as
                // COMPLETAMENTO no longer fits a small iPhone and breaks in half.
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityAddTraits(.isHeader)

            if statistics.completions == 0 {
                // Bare weekday letters and an empty curve would say the same thing twice.
                EmptyHours(text: "Nessun completamento in questo periodo.")
                    .frame(minHeight: height)
            } else {
                charts
            }
        }
    }

    private var charts: some View {
        layout {
            WeekdayChart(weekdays: statistics.weekdays)
                .frame(height: height)

            Group {
                if isAvoided {
                    EmptyHours(text: "Le abitudini da evitare non hanno la curva per ora.")
                } else if statistics.hasHours {
                    HourChart(hours: statistics.hours)
                } else {
                    EmptyHours(text: "Nessun orario in questo periodo: i segni più vecchi non hanno l'ora.")
                }
            }
            .frame(minHeight: height)
        }
    }
}

/// The place of a chart when there is none, saying why.
private struct EmptyHours: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(SbuTheme.footnote)
            .foregroundStyle(SbuTheme.inkMuted)
            .multilineTextAlignment(.center)
            .padding(SbuTheme.space3)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusMd))
    }
}

#Preview("Light") {
    let model = HabitsModel.preview
    CompletionsSection(statistics: .all(model.habits, period: .all, today: model.today, firstWeekday: 2), isAvoided: false)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    let model = HabitsModel.preview
    CompletionsSection(statistics: .all(model.habits, period: .all, today: model.today, firstWeekday: 2), isAvoided: true)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
