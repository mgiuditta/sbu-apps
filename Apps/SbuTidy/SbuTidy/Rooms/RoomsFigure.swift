import SbuKit
import SwiftUI

/// The figure of the rooms screen: how many rooms have nothing to do today.
struct RoomsFigure: View {
    let summaries: [RoomSummary]

    var body: some View {
        let tidy = summaries.filter { !$0.status.hasWork }.count
        SbuStat("Stanze in ordine", value: tidy, format: .number, context: "su \(summaries.count) stanze")
    }
}

private extension RoomSummary.Status {
    var hasWork: Bool { self == .due || self == .overdue }
}

#Preview("Light") {
    RoomsFigure(summaries: [RoomSummary([]), RoomSummary([])])
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentTidy)
}

#Preview("Dark") {
    RoomsFigure(summaries: [RoomSummary([])])
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentTidy)
        .preferredColorScheme(.dark)
}
