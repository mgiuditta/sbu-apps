import SbuKit
import SwiftData
import SwiftUI

/// Every folder as an outline under "Inventario", to choose where something goes.
/// The current place has a checkmark; places it can't go are left out.
struct FolderPicker: View {
    /// The folder chosen now; `nil` is the top of the inventory.
    let selection: Folder?
    /// A folder that can't contain itself: it and everything inside it are left out.
    var excluding: Folder?
    let choose: (Folder?) -> Void

    @Query private var folders: [Folder]
    @ScaledMetric(relativeTo: .body) private var indent = SbuTheme.space4

    var body: some View {
        let tree = InventoryTree(folders: folders.map(\.node), items: [])
        let hidden = excluding.map { tree.subtree(of: $0.uuid) } ?? []
        let byID = Dictionary(folders.map { ($0.uuid, $0) }, uniquingKeysWith: { first, _ in first })
        List {
            Section {
                row(name: String(localized: "Inventario"), systemImage: "tray.full", depth: 0, isSelected: selection == nil) {
                    choose(nil)
                }
                ForEach(tree.outline().filter { !hidden.contains($0.folder.id) }, id: \.folder.id) { entry in
                    row(name: entry.folder.name, systemImage: "folder", depth: entry.depth + 1, isSelected: selection?.uuid == entry.folder.id) {
                        choose(byID[entry.folder.id])
                    }
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
    }

    private func row(name: String, systemImage: String, depth: Int, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: SbuTheme.space3) {
                // Not a `Label`: beside the indent it sized the name to the symbol and clipped it.
                Image(systemName: systemImage)
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .padding(.leading, CGFloat(min(depth, 6)) * indent)
                    .accessibilityHidden(true)
                Text(name)
                    .foregroundStyle(SbuTheme.ink)
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.medium)
                        .foregroundStyle(.tint)
                }
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityValue(depth > 1 ? Text("Livello \(depth)") : Text(verbatim: ""))
    }
}

#Preview("Light") {
    NavigationStack {
        FolderPicker(selection: nil) { _ in }
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack {
        FolderPicker(selection: nil) { _ in }
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
