import SbuKit
import SwiftUI

/// The figure of the rooms screen: how many rooms have nothing to do today. The full stop is set
/// once they all do.
struct RoomsFigure: View {
    let summaries: [RoomSummary]

    var body: some View {
        let tidy = summaries.filter { !$0.hasWork }.count
        SbuFigure(
            value: tidy.formatted(),
            fullStop: !summaries.isEmpty && tidy == summaries.count ? .set : .waiting,
            context: Text("in ordine · su \(summaries.count) stanze"),
            accessibilityLabel: Text("Stanze in ordine: \(tidy) su \(summaries.count)")
        )
        .accessibilityIdentifier("roomsFigure")
    }
}

#Preview("Light") {
    RoomsFigure(summaries: [RoomSummary([]), RoomSummary([])])
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .tidy)
}

#Preview("Dark") {
    RoomsFigure(summaries: [RoomSummary([])])
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .tidy)
        .preferredColorScheme(.dark)
}
