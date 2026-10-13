import SbuKit
import SwiftUI

/// Every way to clean, as rows: the categories that free space, the swipe queues, the bin.
struct HomeList: View {
    let model: CleanModel

    @Environment(\.openURL) private var openURL

    private var duplicatesSubtitle: LocalizedStringKey {
        if case .running(let done, let total) = model.scan {
            return "Analizzo \(done) di \(total)"
        }
        return "\(model.groups.count) gruppi"
    }

    var body: some View {
        let queues = model.queues
        let months = queues.months()
        List {
            if model.access == .limited {
                Section {
                    Text("Vedi solo le foto che hai scelto di condividere con Sbu Clean.")
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                    Button("Apri Impostazioni", action: openSettings)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }

            Section("Libera spazio") {
                row(.duplicates, "Duplicati e simili", subtitle: duplicatesSubtitle, symbol: "square.on.square",
                    bytes: model.bytes(of: model.selectedGroupMembers()))
                categoryRow(.screenshots, route: .grid(.screenshots), "Screenshot", symbol: "camera.viewfinder")
                categoryRow(.screenRecordings, route: .grid(.screenRecordings), "Registrazioni dello schermo", symbol: "record.circle")
                categoryRow(.videos, route: .videos, "Video", symbol: "video")
                row(.livePhotos, "Live Photo", subtitle: "\(model.items(in: .livePhotos).count) Live Photo", symbol: "livephoto",
                    bytes: model.items(in: .livePhotos).reduce(0) { $0 + ($1.size?.pairedVideoBytes ?? 0) })
            }

            Section("Scorri") {
                row(.months, "Mese per mese", subtitle: "\(months.count { $0.isFinished }) finiti su \(months.count)", symbol: "calendar")
                row(.swipe(.recent), "Recenti", subtitle: "\(queues.recentItems.count) da vedere", symbol: "clock")
                row(.swipe(.random), "Casuale", subtitle: "Un giro a caso nella libreria", symbol: "shuffle")
                row(.swipe(.onThisDay), "Accadde oggi", subtitle: "\(queues.onThisDayItems.count) da vedere", symbol: "calendar.badge.clock")
                row(.albums, "Album", subtitle: "Uno alla volta", symbol: "rectangle.stack")
                row(.swipe(.later), "Da decidere dopo", subtitle: "\(model.state.later.count) messi da parte", symbol: "bookmark")
            }

            Section {
                row(.bin, "Cestino", subtitle: "\(model.state.trash.count) elementi", symbol: "trash", bytes: model.trashBytes)
                row(.keepForever, "Da tenere sempre", subtitle: "\(model.state.keepForever.count) elementi", symbol: "lock")
                row(.stats, "Spazio liberato", subtitle: "\(model.state.freed.totalCount) elementi eliminati", symbol: "externaldrive",
                    bytes: model.state.freed.totalBytes)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func row(_ route: Route, _ title: LocalizedStringKey, subtitle: LocalizedStringKey, symbol: String, bytes: Int64? = nil) -> some View {
        NavigationLink(value: route) {
            SbuListRow(title, subtitle: subtitle, systemImage: symbol, iconBackground: SbuTheme.accentClean,
                       amount: bytes.map { $0.formatted(.byteCount(style: .file)) })
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private func categoryRow(_ category: MediaCategory, route: Route, _ title: LocalizedStringKey, symbol: String) -> some View {
        let items = model.items(in: category)
        return row(route, title, subtitle: "\(items.count) elementi", symbol: symbol, bytes: items.reduce(0) { $0 + $1.bytes })
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
