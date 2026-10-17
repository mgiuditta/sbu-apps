import SbuKit
import SwiftUI

/// The picture a Statistiche page is shared as: one page of paper with the habit or Tutte le
/// abitudini, the period, the completion rate as the one figure closed by the full stop, the
/// Serie migliore and the completions, the line over time, the bars by weekday, and the footer.
///
/// It is laid out for `size` points, rendered at `scale`: 1080 × 1920 pixels, the 9:16 of a
/// phone screen and of stories, so it reads like the screen it comes from and fills a phone
/// when opened, without shrinking the charts to fit a squarer frame.
struct StatisticsShareImage: View {
    /// The size it is laid out for, in points: a phone's width, 9:16.
    static let size = CGSize(width: 360, height: 640)
    /// Pixels per point: 1080 × 1920 pixels.
    static let scale: CGFloat = 3

    let share: StatisticsShare

    var body: some View {
        VStack(spacing: SbuTheme.space5) {
            ShareImageHeader(share: share)

            StatisticsFigure(statistics: share.statistics, streakSchedule: share.streakSchedule, showsFullStop: true)

            CompletionLineChart(statistics: share.statistics)

            VStack(spacing: SbuTheme.space2) {
                Text("Completamenti per giorno della settimana")
                    .font(SbuTheme.caption)
                    .textCase(.uppercase)
                    .tracking(SbuTheme.captionTracking)
                    .foregroundStyle(SbuTheme.inkMuted)

                WeekdayChart(weekdays: share.statistics.weekdays)
            }
            .frame(maxHeight: .infinity)

            Text(verbatim: "Sbu Habits · sbu.dev")
                .font(SbuTheme.footnote.weight(.semibold))
                .foregroundStyle(SbuTheme.brand)
        }
        .padding(.horizontal, SbuTheme.space6)
        .padding(.vertical, SbuTheme.space8)
        .frame(width: Self.size.width, height: Self.size.height)
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    StatisticsShareImage(share: .preview(.preview, page: 0, period: .month))
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    StatisticsShareImage(share: .preview(.preview, page: 2, period: .all))
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
