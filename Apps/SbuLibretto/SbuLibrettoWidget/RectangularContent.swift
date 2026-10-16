import SbuKit
import SwiftUI
import WidgetKit

/// The Lock Screen rectangle: the average, then the next sitting and its days.
struct RectangularContent: View {
    let entry: LibrettoWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let average = entry.snapshot?.average {
                Text("Media \(average.formatted(LibrettoFormat.average))")
                    .font(.headline)
                    .widgetAccentable()
            } else {
                Text("Sbu Libretto")
                    .font(.headline)
            }
            if let next = entry.snapshot?.nextExam(now: entry.date, calendar: .current) {
                Text(next.name)
                    .font(.caption)
                    .lineLimit(1)
                Text(verbatim: CountdownDay(next.date, from: entry.date, calendar: .current).text)
                    .font(.caption)
            } else {
                Text("Nessun appello in arrivo")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
