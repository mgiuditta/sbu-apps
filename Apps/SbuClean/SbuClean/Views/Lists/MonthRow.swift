import SbuKit
import SwiftUI

/// One month of the timeline: its name, and on the right the row mark with how many are seen,
/// filled with "Finito" when done.
struct MonthRow: View {
    let progress: MonthProgress

    var body: some View {
        LabeledContent {
            HStack(spacing: SbuTheme.space2) {
                SbuRowMark(filled: progress.isFinished)
                if progress.isFinished {
                    Text("Finito")
                } else {
                    Text("\(progress.decided) di \(progress.total)")
                        .monospacedDigit()
                }
            }
            .foregroundStyle(SbuTheme.inkMuted)
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
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    List {
        MonthRow(progress: MonthProgress(month: YearMonth(year: 2026, month: 9), total: 120, decided: 40))
    }
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
