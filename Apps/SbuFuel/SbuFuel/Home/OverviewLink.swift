import SbuKit
import SwiftUI

/// A row that opens one part of the log, its symbol in ink: the accent belongs to the full stop.
struct OverviewLink: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        Label {
            Text(title)
                .foregroundStyle(SbuTheme.ink)
        } icon: {
            Image(systemName: systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
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
