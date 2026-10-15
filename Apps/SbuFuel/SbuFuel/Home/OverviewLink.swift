import SbuKit
import SwiftUI

/// A row that opens one part of the log, its symbol in ink: the accent belongs to the full stop.
struct OverviewLink: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        // Not a Label: in a list row the audit read its title as clipped, its frame starting under the icon.
        HStack(spacing: SbuTheme.space3) {
            Image(systemName: systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .frame(minWidth: SbuTheme.space6)
                .accessibilityHidden(true)
            Text(title)
                .foregroundStyle(SbuTheme.ink)
        }
    }
}

#Preview("Light") {
    List {
        OverviewLink(title: "Storico", systemImage: "list.bullet.rectangle")
    }
}

#Preview("Dark") {
    List {
        OverviewLink(title: "Storico", systemImage: "list.bullet.rectangle")
    }
    .preferredColorScheme(.dark)
}
