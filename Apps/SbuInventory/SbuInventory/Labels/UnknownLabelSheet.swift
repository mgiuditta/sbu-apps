import SbuKit
import SwiftData
import SwiftUI

/// A label nothing has yet: link it to an item or a box, or add a new item with it.
///
/// The code itself is never shown: it is only a label to find things, not something to read or open.
struct UnknownLabelSheet: View {
    let code: String
    /// Called with the item or folder you linked the label to.
    let linked: (LabelLinker.Owner) -> Void
    /// Called with the item you added with the label.
    let added: (Item) -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var folders: [Folder]
    @Query private var items: [Item]
    @State private var search = ""
    @State private var isAdding = false

    var body: some View {
        let tree = InventoryTree(folders: folders.map(\.node), items: items.map(\.node))
        let query = SearchQuery(search)
        let shownFolders = folders.filter { query.matches(SearchKey.fold($0.name)) }.sorted(by: Self.byName)
        let shownItems = items.filter { query.matches($0.searchKey) }.sorted(by: Self.byName)
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: SbuTheme.space2) {
                        Text("Etichetta nuova")
                            .font(SbuTheme.headline)
                            .foregroundStyle(SbuTheme.ink)
                        Text("Nessun oggetto ha questa etichetta. Collegala a un oggetto o a una scatola: la prossima volta la scansione lo apre.")
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    .accessibilityElement(children: .combine)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
                Section {
                    SbuButton("Aggiungi un oggetto con questa etichetta") { isAdding = true }
                        .accessibilityIdentifier("addWithLabel")
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                if !shownFolders.isEmpty {
                    Section("Collega a una cartella") {
                        ForEach(shownFolders) { folder in
                            Button {
                                link(.folder(folder))
                            } label: {
                                FolderRow(folder: folder, total: tree.total(in: folder.uuid), path: FolderPath.text(tree.path(of: folder.parent?.uuid), root: String(localized: "Inventario")))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
                if !shownItems.isEmpty {
                    Section("Collega a un oggetto") {
                        ForEach(shownItems) { item in
                            Button {
                                link(.item(item))
                            } label: {
                                ItemRow(item: item, path: FolderPath.text(tree.path(of: item.folder?.uuid), root: String(localized: "Inventario")))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .searchable(text: $search, prompt: Text("Cerca"))
            .navigationTitle("Trova dall'etichetta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
            }
            .sheet(isPresented: $isAdding) {
                ItemFormSheet(editor: ItemEditor(mode: .new(folder: nil, code: code)), saved: added)
            }
        }
    }

    private func link(_ owner: LabelLinker.Owner) {
        LabelLinker.link(code, to: owner, in: context)
        InventoryActions.save(context)
        linked(owner)
    }

    private func close() {
        dismiss()
    }

    private static func byName(_ first: Folder, _ second: Folder) -> Bool {
        first.name.localizedStandardCompare(second.name) == .orderedAscending
    }

    private static func byName(_ first: Item, _ second: Item) -> Bool {
        first.name.localizedStandardCompare(second.name) == .orderedAscending
    }
}

#Preview("Light") {
    UnknownLabelSheet(code: "8001234567890", linked: { _ in }, added: { _ in })
        .modelContainer(.preview)
        .environment(\.sbuAccent, .inventory)
}

#Preview("Dark") {
    UnknownLabelSheet(code: "8001234567890", linked: { _ in }, added: { _ in })
        .modelContainer(.preview)
        .environment(\.sbuAccent, .inventory)
        .preferredColorScheme(.dark)
}
