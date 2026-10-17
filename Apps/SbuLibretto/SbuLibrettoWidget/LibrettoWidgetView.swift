import SbuKit
import SwiftUI
import WidgetKit

/// The weighted average closed by the full stop, and under it the next sitting. Before the first
/// grade a waiting "0" and what to do.
struct LibrettoWidgetView: View {
    let entry: LibrettoWidgetEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        let average = entry.snapshot?.average
        SbuWidgetFigure(
            value: average.map { $0.formatted(LibrettoFormat.average) } ?? 0.formatted(),
            label: label(hasAverage: average != nil),
            fullStop: average == nil ? .waiting : .set,
            accent: .libretto
        )
    }

    private func label(hasAverage: Bool) -> Text {
        guard hasAverage else { return Text("Registra il primo voto") }
        // Above the Lock Screen clock there is room for one word.
        guard family != .accessoryInline, let next = entry.snapshot?.nextExam(now: entry.date, calendar: .current) else {
            return Text("Media ponderata")
        }
        let day = CountdownDay(next.date, from: entry.date, calendar: .current).text
        return Text("Media ponderata · \(next.name) · \(day)")
    }
}

#Preview("Small", as: .systemSmall) {
    LibrettoWidget()
} timeline: {
    LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
    LibrettoWidgetEntry(date: .now, snapshot: nil)
}

#Preview("Medium", as: .systemMedium) {
    LibrettoWidget()
} timeline: {
    LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    LibrettoWidget()
} timeline: {
    LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
}

#Preview("Inline", as: .accessoryInline) {
    LibrettoWidget()
} timeline: {
    LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
}
