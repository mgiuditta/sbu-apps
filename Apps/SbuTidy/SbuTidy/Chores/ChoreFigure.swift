import SbuKit
import SwiftUI

/// The figure of a chore, as Tody's: days to its due day, negative when late, and its state.
struct ChoreFigure: View {
    let state: ChoreState

    var body: some View {
        SbuStat("Giorni alla scadenza", value: state.daysUntilDue, format: .number, context: context)
            .accessibilityIdentifier("choreFigure")
    }

    private var context: LocalizedStringKey {
        switch state.status {
        case .clean: "Pulita"
        case .due: "Da fare oggi"
        case .overdue: "In ritardo"
        case .paused: "In pausa: lo sporco non cresce"
        }
    }
}

#Preview("Light") {
    ChoreFigurePreview()
}

#Preview("Dark") {
    ChoreFigurePreview()
        .preferredColorScheme(.dark)
}

private struct ChoreFigurePreview: View {
    var body: some View {
        let now = Date.now
        ChoreFigure(state: ChoreState(frequency: Frequency(7, .day), clock: ChoreClock(lastDone: now.addingTimeInterval(-13 * 86_400)), now: now, calendar: .current))
            .padding(SbuTheme.space4)
            .frame(maxHeight: .infinity)
            .background(SbuTheme.surface)
            .tint(SbuTheme.accentTidy)
    }
}
