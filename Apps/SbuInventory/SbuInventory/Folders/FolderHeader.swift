import SbuKit
import SwiftUI

/// The paper at the top of the inventory and of each folder: the title with its cartiglio, then the
/// total, or the empty state while there is nothing inside (its buttons are rows of their own, below). "Aggiunto" closes the total after a new item.
struct FolderHeader: View {
    /// `nil` for the top of the inventory.
    let name: String?
    /// The folder's place, such as "Casa › Garage"; `nil` at the top.
    let path: String?
    let total: InventoryTotal
    let isEmpty: Bool
    @Binding var isClosing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            if let name {
                SbuScreenTitle(verbatim: name, cartiglio: cartiglio)
            } else {
                SbuScreenTitle("Inventario", cartiglio: cartiglio)
            }
            if isEmpty {
                EmptyFolderView(isTop: name == nil)
            } else {
                SteadyFigure { isPlaceholder in
                    TotalFigure(total: total, isPlaceholder: isPlaceholder)
                        .sbuClosure($isClosing, word: "Aggiunto")
                }
            }
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        // On the row's own content, so the grid and the figure's baseline scroll together.
        .sbuPaper(grid: true)
    }

    /// The metadata line: the app and today's date at the top, the app and the folder's place inside.
    private var cartiglio: String {
        if let path {
            String(localized: "Sbu · Inventario · \(path)")
        } else {
            String(localized: "Sbu · Inventario · \(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))")
        }
    }
}

#Preview("Light") {
    @Previewable @State var isClosing = false
    List {
        FolderHeader(name: nil, path: nil, total: InventoryTotal(quantity: 42, itemCount: 7, folderCount: 4),
                     isEmpty: false, isClosing: $isClosing)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
    }
    .scrollContentBackground(.hidden)
    .background(SbuTheme.paper)
    .environment(\.sbuAccent, .inventory)
}

#Preview("Dark") {
    @Previewable @State var isClosing = false
    List {
        FolderHeader(name: "Garage", path: "Casa › Garage", total: InventoryTotal(),
                     isEmpty: true, isClosing: $isClosing)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
    }
    .scrollContentBackground(.hidden)
    .background(SbuTheme.paper)
    .environment(\.sbuAccent, .inventory)
    .preferredColorScheme(.dark)
}
