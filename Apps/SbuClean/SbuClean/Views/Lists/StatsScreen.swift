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
                    LabeledContent("Spazio", value: freed.lastBytes.sizeText)
                } else {
                    Text("Non hai ancora eliminato niente con Sbu Clean.")
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            if let storage = model.storage {
                Section {
                    LabeledContent("Spazio libero", value: storage.availableBytes.sizeText)
                    LabeledContent("Capacità", value: storage.totalBytes.sizeText)
                } header: {
                    Text("iPhone")
                } footer: {
                    RecentlyDeletedNote()
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        // The figure starts where it does on the other screens.
        .contentMargins(.top, SbuTheme.space4, for: .scrollContent)
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
