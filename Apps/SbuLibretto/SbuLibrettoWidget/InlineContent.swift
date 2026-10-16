import SbuKit
import SwiftUI
import WidgetKit

/// The line above the Lock Screen clock: the next sitting, or the average when none is coming.
struct InlineContent: View {
    let entry: LibrettoWidgetEntry

    var body: some View {
        if let next = entry.snapshot?.nextExam(now: entry.date, calendar: .current) {
            Text(verbatim: "\(next.name) · \(CountdownDay(next.date, from: entry.date, calendar: .current).text)")
        } else if let average = entry.snapshot?.average {
            Text("Media \(average.formatted(LibrettoFormat.average))")
        } else {
            Text("Sbu Libretto")
        }
    }
}
