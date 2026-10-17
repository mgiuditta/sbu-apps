import SbuKit
import SwiftUI

/// A group of ways to clean on the home's paper: a header, then the rows in a `SbuListCard`.
struct HomeGroup: View {
    let title: LocalizedStringKey?
    let entries: [HomeEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            if let title {
                Text(title)
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityAddTraits(.isHeader)
            }
            SbuListCard(entries) { entry in
                HomeEntryRow(entry: entry)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        HomeGroup(title: "Libera spazio", entries: [
            HomeEntry(route: .videos, title: "Video", subtitle: "12 elementi", symbol: "video", bytes: 1_260_000_000),
            HomeEntry(route: .livePhotos, title: "Live Photo", subtitle: "37 elementi", symbol: "livephoto"),
        ])
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
    }
}

#Preview("Dark") {
    NavigationStack {
        HomeGroup(title: nil, entries: [
            HomeEntry(route: .bin, title: "Cestino", subtitle: "12 elementi", symbol: "trash"),
        ])
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
    }
    .preferredColorScheme(.dark)
}
