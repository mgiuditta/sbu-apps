import SbuKit
import SwiftUI

/// Every way to clean, as cards on the home's paper: the categories that free space, the swipe
/// queues, the bin. Not a `List`, so the home scrolls as one page with its figure at every text
/// size.
struct HomeList: View {
    let model: CleanModel

    @Environment(\.openURL) private var openURL

    private var duplicatesSubtitle: LocalizedStringKey {
        if case .running(let done, let total) = model.scan {
            return "Analizzo \(done) di \(total)"
        }
        return "\(model.summary.groupCount) gruppi"
    }

    var body: some View {
        // Everything here comes from the summary, worked out off the main actor: the home stays
        // smooth with tens of thousands of items, even while the scan runs.
        let summary = model.summary
        let months = summary.months
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            if model.access == .limited {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    Text("Vedi solo le foto che hai scelto di condividere con Sbu Clean.")
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                    Button("Apri Impostazioni", action: openSettings)
                        .font(SbuTheme.body)
                }
            }

            HomeGroup(title: "Libera spazio", entries: [
                HomeEntry(route: .duplicates, title: "Duplicati e simili", subtitle: duplicatesSubtitle, symbol: "square.on.square",
                          bytes: summary.selectedGroupBytes),
                category(summary.screenshots, route: .grid(.screenshots), "Screenshot", symbol: "camera.viewfinder"),
                category(summary.screenRecordings, route: .grid(.screenRecordings), "Registrazioni dello schermo", symbol: "record.circle"),
                category(summary.videos, route: .videos, "Video", symbol: "video"),
                HomeEntry(route: .livePhotos, title: "Live Photo", subtitle: "\(summary.livePhotos.count) Live Photo", symbol: "livephoto",
                          bytes: summary.livePhotos.bytes),
            ])

            HomeGroup(title: "Scorri", entries: [
                HomeEntry(route: .months, title: "Mese per mese", subtitle: "\(months.count { $0.isFinished }) finiti su \(months.count)", symbol: "calendar"),
                HomeEntry(route: .swipe(.recent), title: "Recenti", subtitle: "\(summary.recentCount) da vedere", symbol: "clock"),
                HomeEntry(route: .swipe(.random), title: "Casuale", subtitle: "Un giro a caso nella libreria", symbol: "shuffle"),
                HomeEntry(route: .swipe(.onThisDay), title: "Accadde oggi", subtitle: "\(summary.onThisDayCount) da vedere", symbol: "calendar.badge.clock"),
                HomeEntry(route: .albums, title: "Album", subtitle: "Uno alla volta", symbol: "rectangle.stack"),
                HomeEntry(route: .swipe(.later), title: "Da decidere dopo", subtitle: "\(model.state.later.count) messi da parte", symbol: "bookmark"),
            ])

            HomeGroup(title: nil, entries: [
                HomeEntry(route: .bin, title: "Cestino", subtitle: "\(model.state.trash.count) elementi", symbol: "trash", bytes: model.trashBytes),
                HomeEntry(route: .keepForever, title: "Da tenere sempre", subtitle: "\(model.state.keepForever.count) elementi", symbol: "lock"),
                HomeEntry(route: .stats, title: "Spazio liberato", subtitle: "\(model.state.freed.totalCount) elementi eliminati", symbol: "externaldrive",
                          bytes: model.state.freed.totalBytes),
            ])
        }
    }

    private func category(_ category: LibrarySummary.Category, route: Route, _ title: LocalizedStringKey, symbol: String) -> HomeEntry {
        HomeEntry(route: route, title: title, subtitle: "\(category.count) elementi", symbol: symbol, bytes: category.bytes)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
