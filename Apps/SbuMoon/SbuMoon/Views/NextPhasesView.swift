import SbuKit
import SwiftUI

/// The next four principal phases in order, with day and time in the iPhone's time zone, in a card
/// on the paper.
struct NextPhasesView: View {
    let phases: [PhaseEvent]

    private var facts: [MoonFact] {
        phases.map { event in
            MoonFact(
                // One of each principal phase: the phase names the row.
                id: event.phase.storageKey,
                label: event.phase.phase.name,
                value: Text(event.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
            )
        }
    }

    var body: some View {
        SbuListCard(facts) { fact in
            MoonFactRow(fact)
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
            .sbuPaper(grid: true)
    }
}
