import SbuKit
import SwiftUI

/// A folder in a list: its name, how many items are inside at any depth, and how many things in all.
struct FolderRow: View {
    let folder: Folder
    let total: InventoryTotal
    /// The path of the folder it sits in, shown in search results.
    var path: String?

    var body: some View {
        InventoryRowLayout(title: folder.name, quantity: total.quantity) {
            RowTile(image: nil, systemImage: "folder")
        } detail: {
            Group {
                if let path {
                    Text(path)
                } else if total.itemCount == 0 && total.folderCount == 0 {
                    Text("Vuota")
                } else {
                    Text("^[\(total.itemCount) voce](inflect: true)")
                }
            }
            .font(SbuTheme.subheadline)
            .foregroundStyle(SbuTheme.inkMuted)
        }
        .accessibilityIdentifier("folder-\(folder.name)")
    }
}

#Preview("Light") {
    List {
        FolderRow(folder: Folder(name: "Garage"), total: InventoryTotal(quantity: 9, itemCount: 3))
    }
}

#Preview("Dark") {
    List {
        FolderRow(folder: Folder(name: "Garage"), total: InventoryTotal())
    }
    .preferredColorScheme(.dark)
}
