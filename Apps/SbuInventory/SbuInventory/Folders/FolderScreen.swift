import SbuKit
import SwiftData
import SwiftUI

/// The inventory, or one folder of it: the total closed by the full stop, then the folders and the items
/// inside. Searching here searches this folder and everything inside it; at the top, everything.
struct FolderScreen: View {
    /// `nil` for the top of the inventory.
    let folder: Folder?
    /// Opens the label scanner; only the top of the inventory has it.
    var scan: (() -> Void)?

    @Environment(\.modelContext) private var context
    @Query private var folders: [Folder]
    @Query private var items: [Item]
    @State private var search = ""
    @State private var tokens: [TagToken] = []
    @State private var scope = SearchScope.all
    @State private var editor: ItemEditor?
    @State private var moving: InventoryEntry?
    @State private var deleting: InventoryEntry?
    @State private var naming: FolderNaming?
    @State private var isLinkingLabel = false
    @State private var isDeletingSelf = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let tree = InventoryTree(folders: folders.map(\.node), items: items.map(\.node))
        let filter = filter(in: tree)
        let childFolders = folder?.sortedChildren ?? folders.filter { $0.parent == nil }.sorted(by: Self.byName)
        let childItems = folder?.sortedItems ?? items.filter { $0.folder == nil }.sorted(by: Self.byName)
        let isEmpty = childFolders.isEmpty && childItems.isEmpty
        let lowCount = folder == nil ? items.count(where: \.isLow) : 0
        List {
            if filter.isActive {
                SearchResults(
                    folders: matchingFolders(filter, tree: tree),
                    items: items.filter { filter.matches(key: $0.searchKey, tags: $0.tags, isLow: $0.isLow, folderID: $0.folder?.uuid) }.sorted(by: Self.byName),
                    tree: tree,
                    move: { moving = $0 },
                    delete: { deleting = $0 }
                )
            } else if !isEmpty {
                Section {
                    TotalFigure(total: tree.total(in: folder?.uuid))
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                if lowCount > 0 {
                    Section {
                        NavigationLink {
                            LowStockList()
                        } label: {
                            LabeledContent {
                                Text(lowCount, format: .number)
                                    .monospacedDigit()
                            } label: {
                                LowStockBadge()
                                    .font(SbuTheme.body)
                            }
                        }
                        .accessibilityIdentifier("lowStock")
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
                if !childFolders.isEmpty {
                    Section("Cartelle") {
                        ForEach(childFolders) { child in
                            NavigationLink(value: child) {
                                FolderRow(folder: child, total: tree.total(in: child.uuid))
                            }
                            .entryActions(.folder(child), move: { moving = $0 }, delete: { deleting = $0 })
                        }
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
                if !childItems.isEmpty {
                    Section("Oggetti") {
                        ForEach(childItems) { item in
                            NavigationLink(value: item) {
                                ItemRow(item: item)
                            }
                            .entryActions(.item(item), move: { moving = $0 }, delete: { deleting = $0 })
                        }
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .searchable(text: $search, tokens: $tokens, suggestedTokens: .constant(suggestedTokens), prompt: Text(searchPrompt)) { token in
            Label(token.tag, systemImage: "tag")
        }
        .searchScopes($scope, activation: .onSearchPresentation) {
            Text("Tutto").tag(SearchScope.all)
            Text("Da ricomprare").tag(SearchScope.low)
        }
        .overlay {
            if filter.isActive, !hasResults(filter, tree: tree) {
                if search.isEmpty {
                    ContentUnavailableView("Nessun risultato", systemImage: "magnifyingglass")
                } else {
                    ContentUnavailableView.search(text: search)
                }
            } else if !filter.isActive, isEmpty {
                EmptyFolderView(isTop: folder == nil, add: addItem, addSample: addSample)
            }
        }
        .modifier(FolderTitle(name: folder?.name))
        .toolbar { toolbar }
        .sheet(item: $editor) { editor in
            ItemFormSheet(editor: editor)
        }
        .sheet(item: $moving) { entry in
            MoveSheet(entry: entry)
        }
        .sheet(isPresented: $isLinkingLabel) {
            ScanLabelSheet(purpose: .link, found: linkLabel)
        }
        .folderNameAlert($naming)
        .deleteConfirmation($deleting, total: { tree.total(in: $0.uuid) }, intercept: leaveBeforeDeleting)
        .onDisappear(perform: deleteIfLeaving)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        // In ink, like the gear: on this screen the accent belongs to the figure's full stop.
        if let folder {
            ToolbarItemGroup(placement: .topBarTrailing) {
                addMenu
                Menu("Cartella", systemImage: "ellipsis.circle") {
                    Button("Rinomina", systemImage: "pencil") { naming = .rename(folder) }
                    Button("Sposta in", systemImage: "folder") { moving = .folder(folder) }
                    if folder.code == nil {
                        Button("Collega un'etichetta", systemImage: "barcode.viewfinder") { isLinkingLabel = true }
                    } else {
                        Button("Scollega l'etichetta", systemImage: "barcode") { unlinkLabel(folder) }
                    }
                    Button("Elimina cartella", systemImage: "trash", role: .destructive) { deleting = .folder(folder) }
                }
                .tint(SbuTheme.ink)
                .accessibilityIdentifier("folderMenu")
            }
        } else {
            ToolbarItemGroup(placement: .topBarLeading) {
                addMenu
                if let scan {
                    Button("Trova dall'etichetta", systemImage: "barcode.viewfinder", action: scan)
                        .tint(SbuTheme.ink)
                        .accessibilityIdentifier("scan")
                }
            }
        }
    }

    private var addMenu: some View {
        Menu("Aggiungi", systemImage: "plus") {
            Button("Oggetto", systemImage: "shippingbox", action: addItem)
            Button("Cartella", systemImage: "folder.badge.plus") { naming = .create(parent: folder) }
        }
        .tint(SbuTheme.ink)
        .accessibilityIdentifier("add")
    }

    private var searchPrompt: LocalizedStringKey {
        if let folder { "Cerca in \(folder.name)" } else { "Cerca" }
    }

    private var suggestedTokens: [TagToken] {
        let chosen = tokens.map(\.tag)
        return TagList.suggestions(for: search, among: items.flatMap(\.tags), excluding: chosen).prefix(12).map(TagToken.init)
    }

    private func filter(in tree: InventoryTree) -> ItemFilter {
        ItemFilter(
            query: SearchQuery(search),
            tags: tokens.map(\.tag),
            onlyLow: scope == .low,
            folders: folder.map { tree.subtree(of: $0.uuid) }
        )
    }

    /// Folders whose name holds every word, when only words are searched.
    private func matchingFolders(_ filter: ItemFilter, tree: InventoryTree) -> [Folder] {
        guard !filter.query.isEmpty, filter.tags.isEmpty, !filter.onlyLow else { return [] }
        let scope = folder.map { tree.subtree(of: $0.uuid) }
        return folders
            .filter { candidate in
                candidate.uuid != folder?.uuid
                    && (scope?.contains(candidate.uuid) ?? true)
                    && filter.query.matches(SearchKey.fold(candidate.name))
            }
            .sorted(by: Self.byName)
    }

    private func hasResults(_ filter: ItemFilter, tree: InventoryTree) -> Bool {
        !matchingFolders(filter, tree: tree).isEmpty
            || items.contains { filter.matches(key: $0.searchKey, tags: $0.tags, isLow: $0.isLow, folderID: $0.folder?.uuid) }
    }

    private func addItem() {
        editor = ItemEditor(mode: .new(folder: folder, code: nil))
    }

    private func addSample() {
        InventorySample.insert(into: context)
    }

    private func linkLabel(_ code: String) {
        guard let folder else { return }
        LabelLinker.link(code, to: .folder(folder), in: context)
        InventoryActions.save(context)
    }

    private func unlinkLabel(_ folder: Folder) {
        folder.code = nil
        InventoryActions.save(context)
    }

    /// Deleting the folder on screen goes back first and deletes once the screen is gone,
    /// so nothing draws a folder that no longer exists.
    private func leaveBeforeDeleting(_ entry: InventoryEntry) -> Bool {
        guard case let .folder(deleted) = entry, deleted == folder else { return false }
        isDeletingSelf = true
        dismiss()
        return true
    }

    private func deleteIfLeaving() {
        guard isDeletingSelf, let folder else { return }
        InventoryActions.delete(folder, context: context)
    }

    private static func byName(_ first: Folder, _ second: Folder) -> Bool {
        first.name.localizedStandardCompare(second.name) == .orderedAscending
    }

    private static func byName(_ first: Item, _ second: Item) -> Bool {
        first.name.localizedStandardCompare(second.name) == .orderedAscending
    }
}

#Preview("Light") {
    NavigationStack {
        FolderScreen(folder: nil)
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentInventory)
}

#Preview("Dark") {
    NavigationStack {
        FolderScreen(folder: nil)
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentInventory)
    .preferredColorScheme(.dark)
}
