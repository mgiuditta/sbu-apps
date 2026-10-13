import SbuKit
import SwiftUI

/// The timeline, as in the Originale's home: Recenti, Casuale and Accadde oggi on top, then one
/// month per row from the newest, each with how far you got. Native list, one accent, no
/// colored rows.
struct MonthsScreen: View {
    let model: CleanModel

    var body: some View {
        let queues = model.queues
        let byYear = Dictionary(grouping: queues.months(), by: \.month.year)
        List {
            Section {
                SpaceStat(label: "Nel cestino", bytes: model.trashBytes, context: "\(model.state.trash.count) elementi da rivedere")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                queueRow(.recent, count: queues.recentItems.count)
                queueRow(.random, count: nil)
                queueRow(.onThisDay, count: queues.onThisDayItems.count)
                queueRow(.later, count: model.state.later.count)
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            ForEach(byYear.keys.sorted(by: >), id: \.self) { year in
                Section {
                    ForEach(byYear[year] ?? []) { progress in
                        NavigationLink(value: Route.swipe(.month(progress.month))) {
                            MonthRow(progress: progress)
                        }
                    }
                } header: {
                    Text(year, format: .number.grouping(.never))
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Mese per mese")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Route.bin) {
                    Label("Cestino", systemImage: "trash")
                }
                // In ink, as the shell's gear: the accent belongs to the figure's full stop.
                .tint(SbuTheme.ink)
            }
        }
    }

    private func queueRow(_ source: SwipeSource, count: Int?) -> some View {
        NavigationLink(value: Route.swipe(source)) {
            VStack(alignment: .leading, spacing: 0) {
                source.title
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                if let count {
                    Text("\(count) da vedere")
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
        }
    }
}

#Preview("Light") {
    MonthsPreview()
}

#Preview("Dark") {
    MonthsPreview()
        .preferredColorScheme(.dark)
}

private struct MonthsPreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            MonthsScreen(model: model)
        }
        .tint(SbuTheme.accentClean)
        .task {
            await model.reload()
        }
    }
}
