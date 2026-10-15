import SbuKit
import SwiftUI

/// The swipe and context-menu actions every item and folder row has: Sposta in, Elimina.
/// Elimina only asks; the screen confirms before anything goes.
struct EntryActions: ViewModifier {
    let entry: InventoryEntry
    let move: (InventoryEntry) -> Void
    let delete: (InventoryEntry) -> Void

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing) {
                // Not the destructive role: that would take the row away before you confirm.
                Button("Elimina", systemImage: "trash") { delete(entry) }
                    .tint(SbuTheme.danger)
                Button("Sposta in", systemImage: "folder") { move(entry) }
                    .tint(SbuTheme.inkMuted)
            }
            .contextMenu {
                Button("Sposta in", systemImage: "folder") { move(entry) }
                Button("Elimina", systemImage: "trash", role: .destructive) { delete(entry) }
            }
    }
}

extension View {
    func entryActions(_ entry: InventoryEntry, move: @escaping (InventoryEntry) -> Void, delete: @escaping (InventoryEntry) -> Void) -> some View {
        modifier(EntryActions(entry: entry, move: move, delete: delete))
    }
}
