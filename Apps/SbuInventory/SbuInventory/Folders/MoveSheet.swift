import SbuKit
import SwiftData
import SwiftUI

/// "Sposta in": pick the folder an item or a folder goes to.
struct MoveSheet: View {
    let entry: InventoryEntry

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            FolderPicker(selection: entry.currentFolder, excluding: excludedFolder, choose: move)
                .navigationTitle(Text("Sposta «\(entry.name)»"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla", action: close)
                    }
                }
        }
    }

    private var excludedFolder: Folder? {
        if case let .folder(folder) = entry { folder } else { nil }
    }

    private func move(to target: Folder?) {
        switch entry {
        case let .item(item): InventoryActions.move(item, to: target, context: context)
        case let .folder(folder): InventoryActions.move(folder, to: target, context: context)
        }
        dismiss()
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    MoveSheet(entry: .item(Item(name: "Trapano")))
        .modelContainer(.preview)
}

#Preview("Dark") {
    MoveSheet(entry: .item(Item(name: "Trapano")))
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
