import SbuKit
import SwiftUI

/// What Sbu Clean freed: the total as the one figure, the last deletion and the iPhone's space
/// in plain rows. No trophies, no streaks.
struct StatsScreen: View {
    let model: CleanModel

    var body: some View {
        Group {
            if model.state.freed.lastDate == nil {
                EmptyScreen(sentence: "Non hai ancora eliminato niente con Sbu Clean.")
            } else {
                list
            }
        }
        .navigationTitle("Spazio liberato")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var list: some View {
        let freed = model.state.freed
        return List {
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
        .background(SbuTheme.paper)
    }
}

#Preview("Light") {
    NavigationStack {
        StatsScreen(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    NavigationStack {
        StatsScreen(model: .preview)
    }
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
