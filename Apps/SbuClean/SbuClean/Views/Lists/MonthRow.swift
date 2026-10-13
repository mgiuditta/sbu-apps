import SbuKit
import SwiftUI

/// One month of the timeline: its name, and on the right a ring with how many are seen, or
/// "Finito" with a check when done.
struct MonthRow: View {
    let progress: MonthProgress

    @ScaledMetric(relativeTo: .body) private var ringSide: CGFloat = 22

    var body: some View {
        LabeledContent {
            if progress.isFinished {
                Label("Finito", systemImage: "checkmark")
                    .foregroundStyle(SbuTheme.inkMuted)
            } else {
                HStack(spacing: SbuTheme.space2) {
                    Text("\(progress.decided) di \(progress.total)")
                        .monospacedDigit()
                        .foregroundStyle(SbuTheme.inkMuted)
                    ProgressRing(fraction: progress.fraction)
                        .frame(width: ringSide, height: ringSide)
                }
            }
        } label: {
            Text(progress.month.firstDay(in: .current), format: .dateTime.month(.wide))
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    List {
        MonthRow(progress: MonthProgress(month: YearMonth(year: 2026, month: 9), total: 120, decided: 40))
        MonthRow(progress: MonthProgress(month: YearMonth(year: 2026, month: 8), total: 80, decided: 80))
    }
    .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    List {
        MonthRow(progress: MonthProgress(month: YearMonth(year: 2026, month: 9), total: 120, decided: 40))
    }
    .tint(SbuTheme.accentClean)
    .preferredColorScheme(.dark)
}
