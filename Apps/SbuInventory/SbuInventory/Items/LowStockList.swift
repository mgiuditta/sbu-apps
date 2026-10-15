import SbuKit
import SwiftData
import SwiftUI

/// Everything at or below its minimum, from every folder: the shopping list.
struct LowStockList: View {
    @Query private var folders: [Folder]
    @Query private var items: [Item]
    @State private var moving: InventoryEntry?
    @State private var deleting: InventoryEntry?

    var body: some View {
        let tree = InventoryTree(folders: folders.map(\.node), items: items.map(\.node))
        let low = items.filter(\.isLow).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        List {
            SearchResults(folders: [], items: low, tree: tree, move: { moving = $0 }, delete: { deleting = $0 })
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .overlay {
            if low.isEmpty {
                ContentUnavailableView("Niente da ricomprare", systemImage: "cart", description: Text("Gli oggetti arrivati alla quantità minima compaiono qui."))
            }
        }
        .navigationTitle("Da ricomprare")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $moving) { entry in
            MoveSheet(entry: entry)
        }
        .deleteConfirmation($deleting, total: { tree.total(in: $0.uuid) })
    }
}

#Preview("Light") {
    NavigationStack {
        LowStockList()
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack {
        LowStockList()
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
