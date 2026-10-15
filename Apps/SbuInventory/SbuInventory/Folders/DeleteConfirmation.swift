import SwiftData
import SwiftUI

/// Asks before deleting an item or a folder, saying what goes with a folder.
/// An alert, not a bubble, so it reads whole at the largest text sizes too.
struct DeleteConfirmation: ViewModifier {
    @Binding var entry: InventoryEntry?
    /// What the folder being deleted holds.
    let total: (Folder) -> InventoryTotal
    /// Takes the deletion over when it returns `true`, as the folder on screen does to leave first.
    var intercept: (InventoryEntry) -> Bool = { _ in false }

    @Environment(\.modelContext) private var context

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented, presenting: entry) { entry in
                Button("Elimina", role: .destructive) { delete(entry) }
                Button("Annulla", role: .cancel) {}
            } message: { entry in
                message(for: entry)
            }
    }

    private var title: Text {
        Text("Eliminare «\(entry?.name ?? "")»?")
    }

    private var isPresented: Binding<Bool> {
        Binding { entry != nil } set: { if !$0 { entry = nil } }
    }

    private func message(for entry: InventoryEntry) -> Text {
        switch entry {
        case .item:
            return Text("Non si può annullare.")
        case let .folder(folder):
            let inside = total(folder)
            switch (inside.itemCount, inside.folderCount) {
            case (0, 0): return Text("La cartella è vuota.")
            case let (items, 0): return Text("Va via anche quello che contiene: ^[\(items) voce](inflect: true), con le foto.")
            case let (0, folders): return Text("Va via anche quello che contiene: ^[\(folders) cartella](inflect: true).")
            case let (items, folders): return Text("Va via anche quello che contiene: ^[\(items) voce](inflect: true) e ^[\(folders) cartella](inflect: true), con le foto.")
            }
        }
    }

    private func delete(_ entry: InventoryEntry) {
        guard !intercept(entry) else { return }
        switch entry {
        case let .item(item): InventoryActions.delete(item, context: context)
        case let .folder(folder): InventoryActions.delete(folder, context: context)
        }
    }
}

extension View {
    func deleteConfirmation(_ entry: Binding<InventoryEntry?>, total: @escaping (Folder) -> InventoryTotal, intercept: @escaping (InventoryEntry) -> Bool = { _ in false }) -> some View {
        modifier(DeleteConfirmation(entry: entry, total: total, intercept: intercept))
    }
}
