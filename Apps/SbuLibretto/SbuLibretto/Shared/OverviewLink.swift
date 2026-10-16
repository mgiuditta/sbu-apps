import SbuKit
import SwiftUI

/// A row that opens one part of the libretto, its symbol in inkMuted: the accent belongs to the full stop.
/// An optional detail on the right, such as the days to the next sitting.
struct OverviewLink: View {
    let title: LocalizedStringKey
    let systemImage: String
    var detail: String?

    var body: some View {
        // Not a Label: in a list row the audit read its title as clipped, its frame starting under the icon.
        HStack(spacing: SbuTheme.space3) {
            Image(systemName: systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .frame(minWidth: SbuTheme.space6)
                .accessibilityHidden(true)
            titleText
                // The title takes its room first; at large text the detail wraps on its side, never cut.
                .layoutPriority(1)
            if let detail {
                Spacer(minLength: SbuTheme.space2)
                detailText(detail)
            }
        }
    }

    private var titleText: some View {
        Text(title)
            .foregroundStyle(SbuTheme.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func detailText(_ detail: String) -> some View {
        Text(verbatim: detail)
            .foregroundStyle(SbuTheme.inkMuted)
            .multilineTextAlignment(.trailing)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("Light") {
    List {
        OverviewLink(title: "Piano di studi", systemImage: "list.bullet.rectangle")
    }
}

#Preview("Dark") {
    List {
        OverviewLink(title: "Piano di studi", systemImage: "list.bullet.rectangle")
    }
    .preferredColorScheme(.dark)
}
