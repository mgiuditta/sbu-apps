import SbuKit
import SwiftUI

/// Every way to clean, as grouped rows: the categories that free space, the swipe queues, the
/// bin. Not a `List`, so the home scrolls as one page with its figure at every text size.
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
                HomeGroup(title: nil) {
                    VStack(alignment: .leading, spacing: SbuTheme.space2) {
                        Text("Vedi solo le foto che hai scelto di condividere con Sbu Clean.")
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                        Button("Apri Impostazioni", action: openSettings)
                            .font(SbuTheme.body)
                    }
                    .padding(SbuTheme.space4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            HomeGroup(title: "Libera spazio") {
                row(.duplicates, "Duplicati e simili", subtitle: duplicatesSubtitle, symbol: "square.on.square",
                    bytes: summary.selectedGroupBytes)
                HomeRowDivider()
                categoryRow(summary.screenshots, route: .grid(.screenshots), "Screenshot", symbol: "camera.viewfinder")
                HomeRowDivider()
                categoryRow(summary.screenRecordings, route: .grid(.screenRecordings), "Registrazioni dello schermo", symbol: "record.circle")
                HomeRowDivider()
                categoryRow(summary.videos, route: .videos, "Video", symbol: "video")
                HomeRowDivider()
                row(.livePhotos, "Live Photo", subtitle: "\(summary.livePhotos.count) Live Photo", symbol: "livephoto",
                    bytes: summary.livePhotos.bytes)
            }

            HomeGroup(title: "Scorri") {
                row(.months, "Mese per mese", subtitle: "\(months.count { $0.isFinished }) finiti su \(months.count)", symbol: "calendar")
                HomeRowDivider()
                row(.swipe(.recent), "Recenti", subtitle: "\(summary.recentCount) da vedere", symbol: "clock")
                HomeRowDivider()
                row(.swipe(.random), "Casuale", subtitle: "Un giro a caso nella libreria", symbol: "shuffle")
                HomeRowDivider()
                row(.swipe(.onThisDay), "Accadde oggi", subtitle: "\(summary.onThisDayCount) da vedere", symbol: "calendar.badge.clock")
                HomeRowDivider()
                row(.albums, "Album", subtitle: "Uno alla volta", symbol: "rectangle.stack")
                HomeRowDivider()
                row(.swipe(.later), "Da decidere dopo", subtitle: "\(model.state.later.count) messi da parte", symbol: "bookmark")
            }

            HomeGroup(title: nil) {
                row(.bin, "Cestino", subtitle: "\(model.state.trash.count) elementi", symbol: "trash", bytes: model.trashBytes)
                HomeRowDivider()
                row(.keepForever, "Da tenere sempre", subtitle: "\(model.state.keepForever.count) elementi", symbol: "lock")
                HomeRowDivider()
                row(.stats, "Spazio liberato", subtitle: "\(model.state.freed.totalCount) elementi eliminati", symbol: "externaldrive",
                    bytes: model.state.freed.totalBytes)
            }
        }
    }

    private func row(_ route: Route, _ title: LocalizedStringKey, subtitle: LocalizedStringKey, symbol: String, bytes: Int64? = nil) -> some View {
        NavigationLink(value: route) {
            HStack(spacing: SbuTheme.space2) {
                SbuListRow(title, subtitle: subtitle, systemImage: symbol, iconBackground: SbuTheme.accentClean,
                           amount: bytes.flatMap { $0 > 0 ? $0.sizeText : nil })
                Image(systemName: "chevron.forward")
                    .font(SbuTheme.footnote.weight(.semibold))
                    .foregroundStyle(SbuTheme.inkMuted)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space3)
        }
        .buttonStyle(HomeRowStyle())
        .accessibilityIdentifier("home.\(route.identifier)")
    }

    private func categoryRow(_ category: LibrarySummary.Category, route: Route, _ title: LocalizedStringKey, symbol: String) -> some View {
        row(route, title, subtitle: "\(category.count) elementi", symbol: symbol, bytes: category.bytes)
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
    .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: .preview)
    }
    .tint(SbuTheme.accentClean)
    .preferredColorScheme(.dark)
}
