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
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space4) {
                SpaceStat(label: "Selezionati", bytes: bytes, context: "\(selection.count) di \(items.count)")

                if items.isEmpty {
                    Text("Niente qui.")
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                } else {
                    NavigationLink("Scorri uno per uno", value: Route.swipe(.category(category)))
                        .buttonStyle(SbuFieldPillStyle())
                }

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
        .background(SbuTheme.surface)
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(selection.count == items.count && !items.isEmpty ? "Deseleziona tutto" : "Seleziona tutto") {
                    selection = selection.count == items.count ? [] : Set(items.map(\.id))
                }
                .disabled(items.isEmpty)
            }
        }
        .bottomAction {
            SbuButton(DeleteTitle.forBytes(bytes)) {
                model.moveToTrash(items.map(\.id).filter(selection.contains))
                selection = []
                showsBin = true
            }
            .disabled(selection.isEmpty)
        }
        .navigationDestination(isPresented: $showsBin) {
            BinScreen(model: model)
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
        .tint(SbuTheme.accentClean)
        .task {
            await model.reload()
        }
    }
}
