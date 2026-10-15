import SbuKit
import SwiftUI

/// What the search found, from every folder searched, each with the path to where it is.
struct SearchResults: View {
    let folders: [Folder]
    let items: [Item]
    let tree: InventoryTree
    let move: (InventoryEntry) -> Void
    let delete: (InventoryEntry) -> Void

    var body: some View {
        if !folders.isEmpty {
            Section("Cartelle") {
                ForEach(folders) { folder in
                    NavigationLink(value: folder) {
                        FolderRow(folder: folder, total: tree.total(in: folder.uuid), path: path(of: folder.parent))
                    }
                    .entryActions(.folder(folder), move: move, delete: delete)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        if !items.isEmpty {
            Section("Oggetti") {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        ItemRow(item: item, path: path(of: item.folder))
                    }
                    .entryActions(.item(item), move: move, delete: delete)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
    }

    private func path(of folder: Folder?) -> String {
        FolderPath.text(tree.path(of: folder?.uuid), root: String(localized: "Inventario"))
    }
}
