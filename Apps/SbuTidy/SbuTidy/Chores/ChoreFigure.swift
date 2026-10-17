import SbuKit
import SwiftUI

/// The figure of a chore, as Tody's: days to its due day, negative when late, and its state. The
/// full stop is set while the chore is clean and waits while it is to do or paused.
struct ChoreFigure: View {
    let state: ChoreState

    var body: some View {
        SbuFigure(
            value: state.daysUntilDue.formatted(),
            fullStop: state.status == .clean ? .set : .waiting,
            context: Text("giorni alla scadenza · \(Text(status))"),
            accessibilityLabel: Text("Giorni alla scadenza: \(state.daysUntilDue). \(Text(status))")
        )
        .accessibilityIdentifier("choreFigure")
    }

    private var status: LocalizedStringKey {
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
            .frame(maxHeight: .infinity, alignment: .top)
            .sbuPaper(grid: true)
            .environment(\.sbuAccent, .tidy)
    }
}
