import SbuKit
import SwiftUI

/// The time as the screen's one figure, closed by the full stop: the ringing alarm and the
/// bedside clock.
struct ClockFigure: View {
    let date: Date

    var body: some View {
        SbuFigure(value: date.formatted(.dateTime.hour().minute()))
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Light") {
    ClockFigure(date: .now)
        .padding(SbuTheme.space4)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .noise)
}

#Preview("Dark") {
    ClockFigure(date: .now)
        .padding(SbuTheme.space4)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .noise)
        .preferredColorScheme(.dark)
}
