import SbuKit
import SwiftUI
import WidgetKit

/// The next sitting and the days to it, or that there is none.
struct NextExamBlock: View {
    let entry: LibrettoWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let next = entry.snapshot?.nextExam(now: entry.date, calendar: .current) {
                Text(next.name)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.ink)
                    .lineLimit(2)
                Text(verbatim: CountdownDay(next.date, from: entry.date, calendar: .current).text)
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            } else {
                Text("Nessun appello in arrivo")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
    }
}
