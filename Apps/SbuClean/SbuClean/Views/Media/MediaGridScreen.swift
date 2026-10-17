import SbuKit
import SwiftUI

/// Screenshots or screen recordings in a grid, biggest first: select them, or swipe through
/// them, and send them to the bin.
struct MediaGridScreen: View {
    let model: CleanModel
    let category: MediaCategory

    @State private var selection: Set<String> = []
    @State private var showsBin = false

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: SbuTheme.space1)]

    var body: some View {
        let items = model.items(in: category).filter { !model.state.trash.contains($0.id) }
        let bytes = model.bytes(of: selection)
        Group {
            if items.isEmpty {
                EmptyScreen(sentence: category == .screenshots
                            ? "Nessuno screenshot nella libreria."
                            : "Nessuna registrazione dello schermo nella libreria.")
            } else {
                grid(items, bytes: bytes)
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showsBin) {
            BinScreen(model: model)
        }
    }

    private func grid(_ items: [MediaItem], bytes: Int64) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space4) {
                SpaceStat(label: "Selezionati", bytes: bytes, context: "\(selection.count) di \(items.count)")

                NavigationLink("Scorri uno per uno", value: Route.swipe(.category(category)))
                    .buttonStyle(SbuFieldPillStyle())

                LazyVGrid(columns: columns, spacing: SbuTheme.space1) {
                    ForEach(items) { item in
                        MediaGridTile(item: item, isSelected: selection.contains(item.id)) {
                            toggle(item.id)
                        }
                    }
                }
            }
            .padding(SbuTheme.space4)
        }
        .background(SbuTheme.paper)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(selection.count == items.count ? "Deseleziona tutto" : "Seleziona tutto") {
                    selection = selection.count == items.count ? [] : Set(items.map(\.id))
                }
            }
        }
        .bottomAction {
            SbuButton(DeleteTitle.forBytes(bytes)) {
                model.moveToTrash(items.map(\.id).filter(selection.contains))
                selection = []
                showsBin = true
            }
            .disabled(selection.isEmpty)
            .accessibilityIdentifier("bottomAction")
        }
    }

    private func toggle(_ id: String) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }
}

#Preview("Light") {
    MediaGridPreview()
}

#Preview("Dark") {
    MediaGridPreview()
        .preferredColorScheme(.dark)
}

private struct MediaGridPreview: View {
    @State private var model = CleanModel.preview

    var body: some View {
        NavigationStack {
            MediaGridScreen(model: model, category: .screenshots)
        }
        .environment(\.sbuAccent, .clean)
        .task {
            await model.reload()
        }
    }
}
