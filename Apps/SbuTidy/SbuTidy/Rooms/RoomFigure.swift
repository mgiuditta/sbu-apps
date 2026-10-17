import SbuKit
import SwiftUI

/// The figure of a room: its chores to do today. The full stop is set once none is left.
struct RoomFigure: View {
    let summary: RoomSummary

    var body: some View {
        SbuFigure(
            value: summary.toDoCount.formatted(),
            fullStop: summary.choreCount > 0 && summary.toDoCount == 0 ? .set : .waiting,
            context: Text(context),
            accessibilityLabel: Text("Da fare oggi: \(summary.toDoCount). \(Text(context))")
        )
        .accessibilityIdentifier("roomFigure")
    }

    private var context: LocalizedStringKey {
        if summary.overdueCount > 0 { return "da fare oggi · \(summary.overdueCount) in ritardo" }
        return "da fare oggi · su \(summary.choreCount) attività"
    }
}

#Preview("Light") {
    RoomFigure(summary: RoomSummary([]))
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .tidy)
}

#Preview("Dark") {
    RoomFigure(summary: RoomSummary([]))
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .tidy)
        .preferredColorScheme(.dark)
}
