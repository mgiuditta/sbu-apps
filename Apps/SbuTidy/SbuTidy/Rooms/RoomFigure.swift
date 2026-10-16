import SbuKit
import SwiftUI

/// The figure of a room: its chores to do today.
struct RoomFigure: View {
    let summary: RoomSummary

    var body: some View {
        SbuStat("Da fare oggi", value: summary.toDoCount, format: .number, context: context)
    }

    private var context: LocalizedStringKey {
        if summary.overdueCount > 0 { return "di cui \(summary.overdueCount) in ritardo" }
        return "su \(summary.choreCount) attività"
    }
}

#Preview("Light") {
    RoomFigure(summary: RoomSummary([]))
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentTidy)
}

#Preview("Dark") {
    RoomFigure(summary: RoomSummary([]))
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentTidy)
        .preferredColorScheme(.dark)
}
