import SbuKit
import SwiftUI

/// What Sbu Clean freed: the total as the one figure, the last deletion and the iPhone's space
/// in plain rows. No trophies, no streaks.
struct StatsScreen: View {
    let model: CleanModel

    var body: some View {
        let freed = model.state.freed
        List {
            Section {
                SpaceStat(label: "Spazio liberato", bytes: freed.totalBytes, context: "\(freed.totalCount) elementi eliminati in tutto")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                if let date = freed.lastDate {
                    LabeledContent("Ultima eliminazione", value: date.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("Elementi", value: freed.lastCount.formatted())
                    LabeledContent("Spazio", value: freed.lastBytes.formatted(.byteCount(style: .file)))
                } else {
                    Text("Non hai ancora eliminato niente con Sbu Clean.")
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            if let storage = model.storage {
                Section {
                    LabeledContent("Spazio libero", value: storage.availableBytes.formatted(.byteCount(style: .file)))
                    LabeledContent("Capacità", value: storage.totalBytes.formatted(.byteCount(style: .file)))
                } header: {
                    Text("iPhone")
                } footer: {
                    RecentlyDeletedNote()
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Spazio liberato")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack {
        StatsScreen(model: .preview)
    }
    .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    NavigationStack {
        StatsScreen(model: .preview)
    }
    .tint(SbuTheme.accentClean)
    .preferredColorScheme(.dark)
}
