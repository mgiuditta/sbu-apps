import SbuKit
import SwiftUI

/// A row that opens one part of the log, its symbol in inkMuted: the accent belongs to the full stop.
struct OverviewLink: View {
    let destination: OverviewDestination

    var body: some View {
        // Not a Label: the audit read its title as clipped, its frame starting under the icon.
        HStack(spacing: SbuTheme.space3) {
            Image(systemName: destination.systemImage)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .frame(minWidth: SbuTheme.space6)
                .accessibilityHidden(true)
            Text(destination.title)
                .foregroundStyle(SbuTheme.ink)
            Spacer(minLength: 0)
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
}

#Preview("Light") {
    SbuListCard(OverviewDestination.allCases) { destination in
        OverviewLink(destination: destination)
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    SbuListCard(OverviewDestination.allCases) { destination in
        OverviewLink(destination: destination)
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
    .preferredColorScheme(.dark)
}
