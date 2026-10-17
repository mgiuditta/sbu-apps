import SbuKit
import SwiftUI

/// A row of the home's cards: the symbol, the title and what is there, the space on the right in
/// `statSmall`, and the chevron. It opens the entry's screen.
struct HomeEntryRow: View {
    let entry: HomeEntry

    @ScaledMetric(relativeTo: .body) private var symbolWidth: CGFloat = 28

    var body: some View {
        NavigationLink(value: entry.route) {
            HStack(spacing: SbuTheme.space2) {
                // As `SbuListRow` lays it out: the text wraps first, the space keeps its width.
                HStack(spacing: SbuTheme.space3) {
                    Image(systemName: entry.symbol)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .frame(width: symbolWidth)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(entry.title)
                            .font(SbuTheme.headline)
                            .foregroundStyle(SbuTheme.ink)
                        Text(entry.subtitle)
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let bytes = entry.bytes, bytes > 0 {
                    Text(bytes.sizeText)
                        .font(SbuTheme.statSmall)
                        .foregroundStyle(SbuTheme.ink)
                        .fixedSize(horizontal: true, vertical: false)
                }
                Image(systemName: "chevron.forward")
                    .font(SbuTheme.footnote.weight(.semibold))
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
            .contentShape(.rect)
            // One element inside the link, as a list row reads: title, what is there, the space.
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.\(entry.route.identifier)")
    }
}

#Preview("Light") {
    HomeEntryRowPreview()
}

#Preview("Dark") {
    HomeEntryRowPreview()
        .preferredColorScheme(.dark)
}

private struct HomeEntryRowPreview: View {
    var body: some View {
        NavigationStack {
            SbuListCard([
                HomeEntry(route: .duplicates, title: "Duplicati e simili", subtitle: "12 elementi", symbol: "square.on.square", bytes: 18_840_000),
                HomeEntry(route: .albums, title: "Album", subtitle: "Uno alla volta", symbol: "rectangle.stack"),
            ]) { entry in
                HomeEntryRow(entry: entry)
            }
            .padding(SbuTheme.space4)
            .frame(maxHeight: .infinity, alignment: .top)
            .sbuPaper()
        }
    }
}
