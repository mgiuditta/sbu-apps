import SbuKit
import SwiftData
import SwiftUI

/// The top of the inventory, where every folder and item screen is pushed from, and the label scan:
/// a known label opens its item or box, an unknown one offers to link it.
struct InventoryHome: View {
    @Environment(\.modelContext) private var context
    @State private var sheet: HomeSheet?
    /// A label just read, followed once the scanner has gone: a sheet never replaces another while it is up.
    @State private var scannedCode: String?
    /// What to open once the sheet has gone, so the push never races the sheet going down.
    @State private var pendingOwner: LabelLinker.Owner?
    @State private var openedItem: Item?
    @State private var openedFolder: Folder?

    var body: some View {
        FolderScreen(folder: nil, scan: { sheet = .scan })
            .navigationDestination(for: Folder.self) { folder in
                FolderScreen(folder: folder)
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
            .navigationDestination(item: $openedItem) { item in
                ItemDetailView(item: item)
            }
            .navigationDestination(item: $openedFolder) { folder in
                FolderScreen(folder: folder)
            }
            .sheet(item: $sheet, onDismiss: sheetDismissed) { sheet in
                switch sheet {
                case .scan:
                    ScanLabelSheet(purpose: .find) { scannedCode = $0 }
                case let .unknown(code):
                    UnknownLabelSheet(code: code, linked: show)
                }
            }
    }

    /// After a sheet: opens what a scanned label belongs to or offers to link it, or opens what was just linked.
    private func sheetDismissed() {
        if let code = scannedCode {
            scannedCode = nil
            switch LabelLinker.owner(of: code, in: context) {
            case let .some(owner): open(owner)
            case nil: sheet = .unknown(code)
            }
        } else if let owner = pendingOwner {
            pendingOwner = nil
            open(owner)
        }
    }

    /// Closes the unknown-label sheet, then opens what now has the label.
    private func show(_ owner: LabelLinker.Owner) {
        pendingOwner = owner
        sheet = nil
    }

    private func open(_ owner: LabelLinker.Owner) {
        switch owner {
        case let .item(item): openedItem = item
        case let .folder(folder): openedFolder = folder
        }
    }
}

#Preview("Light") {
    NavigationStack {
        InventoryHome()
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentInventory)
}

#Preview("Dark") {
    NavigationStack {
        InventoryHome()
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentInventory)
    .preferredColorScheme(.dark)
}
