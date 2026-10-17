import SbuKit
import SwiftUI
import WidgetKit

/// The complication: on a round slot, today's habits done as a ring around the Serie piena; on a
/// rectangle, the Serie piena as `SbuWidgetFigure`, with today's habits done as its label. With no
/// grid for today, a word to open the iPhone app, which sends it.
struct ComplicationView: View {
    @Environment(\.widgetFamily) private var family

    let entry: ComplicationEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // SbuWidgetFigure sets the container background itself.
            ComplicationRectangular(today: entry.today)
        default:
            ComplicationCircular(today: entry.today)
                // On the watch face: no background of its own.
                .containerBackground(for: .widget) {}
        }
    }
}

#Preview("Circular", as: .accessoryCircular) {
    HabitsComplication()
} timeline: {
    ComplicationEntry.sample
    ComplicationEntry(date: .now, today: nil)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    HabitsComplication()
} timeline: {
    ComplicationEntry.sample
    ComplicationEntry(date: .now, today: nil)
}
