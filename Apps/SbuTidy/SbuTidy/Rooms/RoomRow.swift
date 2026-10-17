import SbuKit
import SwiftUI

/// A room in the rooms list: its symbol in ink on a sunken tile, name and chore count, and its
/// state in words; the accent belongs to the figure's full stop alone.
struct RoomRow: View {
    let name: String
    let kind: RoomKind
    let summary: RoomSummary

    var body: some View {
        SbuListRow(
            "\(name)",
            subtitle: "\(summary.choreCount) attività",
            systemImage: kind.symbol,
            iconBackground: SbuTheme.surfaceSunken,
            iconForeground: SbuTheme.ink,
            status: "\(Text(summary.statusText))"
        )
    }
}

#Preview("Light") {
    RoomRowPreview()
}

#Preview("Dark") {
    RoomRowPreview()
        .preferredColorScheme(.dark)
}

private struct RoomRowPreview: View {
    var body: some View {
        List {
            RoomRow(name: "Cucina", kind: .kitchen, summary: RoomSummary([]))
            RoomRow(name: "Bagno", kind: .bathroom, summary: RoomSummary([]))
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
    }
}
