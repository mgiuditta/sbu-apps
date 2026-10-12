import SbuKit
import SwiftUI

/// The next four principal phases in order, with day and time in the iPhone's time zone.
struct NextPhasesView: View {
    let phases: [PhaseEvent]

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            ForEach(phases, id: \.date) { event in
                MoonFactRow(
                    event.phase.phase.name,
                    value: Text(event.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
                )
            }
        }
    }
}

#Preview("Light") {
    NextPhasesPreview()
}

#Preview("Dark") {
    NextPhasesPreview()
        .preferredColorScheme(.dark)
}

private struct NextPhasesPreview: View {
    var body: some View {
        NextPhasesView(phases: MoonReading(date: .now, calendar: .current).upcomingPhases)
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SbuTheme.surface)
    }
}
