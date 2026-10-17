import SbuKit
import SwiftUI

/// A row that opens one part of the libretto, its symbol in inkMuted: the accent belongs to the full stop.
/// An optional detail on the right, such as the days to the next sitting.
struct OverviewLink: View {
    let title: LocalizedStringKey
    let systemImage: String
    var detail: String?

    var body: some View {
        // Not a Label: the audit read its title as clipped, its frame starting under the icon.
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
            Spacer(minLength: SbuTheme.space2)
            if let detail {
                detailText(detail)
            }
            // On paper a link draws its own chevron, as a List row would.
            Image(systemName: "chevron.forward")
                .font(SbuTheme.footnote)
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
        }
        // The whole row is the target, at least 44 pt tall.
        .frame(maxWidth: .infinity, minHeight: SbuTheme.controlRoundSm, alignment: .leading)
        .contentShape(.rect)
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
    SbuListCard(DashboardDestination.allCases) { destination in
        OverviewLink(title: destination.title, systemImage: destination.systemImage, detail: destination == .upcoming ? "Tra 12 giorni" : nil)
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    SbuListCard(DashboardDestination.allCases) { destination in
        OverviewLink(title: destination.title, systemImage: destination.systemImage)
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
    .preferredColorScheme(.dark)
}
