import SbuKit
import SwiftData
import SwiftUI

/// One item: its photos, how many (the figure of this screen) with − and +, where it is, what it is worth,
/// its fields, tags, label and notes. Opened right after it was added, "Aggiunto" closes the figure once.
struct ItemDetailView: View {
    @Bindable var item: Item
    /// Whether the item was just added, as from a scanned label: the Closure plays when the screen appears.
    var isNew = false

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var folders: [Folder]
    @State private var editor: ItemEditor?
    @State private var moving: InventoryEntry?
    @State private var isDeleting = false
    @State private var isClosing = false
    @State private var hasClosed = false

    var body: some View {
        let photos = item.sortedPhotos
        List {
            if !photos.isEmpty {
                Section {
                    PhotoCarousel(photos: photos)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            Section {
                figure
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            Section {
                Stepper(value: quantity, in: 0...999_999) {
                    Text("Cambia la quantità")
                }
                .sbuAffectsFigure(item.quantity)
                .accessibilityIdentifier("quantityStepper")
                if let minimum = item.minimumQuantity {
                    LabeledContent("Quantità minima") {
                        Text(minimum, format: .number)
                    }
                    if item.isLow {
                        LowStockBadge()
                    }
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            Section("Posizione") {
                Button {
                    moving = .item(item)
                } label: {
                    LabeledContent {
                        Text("Sposta")
                    } label: {
                        Label {
                            Text(path)
                                .foregroundStyle(SbuTheme.ink)
                        } icon: {
                            Image(systemName: "folder")
                                .fontWeight(.medium)
                                .foregroundStyle(SbuTheme.inkMuted)
                        }
                    }
                }
                .accessibilityLabel(Text(path))
                .accessibilityHint(Text("Sposta in un'altra cartella"))
                .accessibilityIdentifier("itemPath")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            if item.unitPrice != nil || item.purchaseDate != nil {
                Section("Valore") {
                    if let price = item.unitPrice {
                        LabeledContent("Prezzo di uno") {
                            Text(price, format: InventoryCurrency.format)
                        }
                    }
                    if let date = item.purchaseDate {
                        LabeledContent("Data d'acquisto") {
                            Text(date, format: .dateTime.day().month(.wide).year())
                        }
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            let values = item.sortedFieldValues.filter { !$0.isEmpty }
            if !values.isEmpty {
                Section("Campi") {
                    ForEach(values) { value in
                        FieldValueRow(value: value)
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            if !item.tags.isEmpty {
                Section("Tag") {
                    FlowLayout(spacing: SbuTheme.space2) {
                        ForEach(item.tags, id: \.self) { tag in
                            TagChip(tag: tag)
                        }
                    }
                    .padding(.vertical, SbuTheme.space1)
                    .accessibilityElement(children: .combine)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            if let code = item.code {
                Section("Etichetta") {
                    LabeledContent("Codice", value: code)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            if !item.notes.isEmpty {
                Section("Note") {
                    Text(item.notes)
                        .foregroundStyle(SbuTheme.ink)
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            Section {
                SbuButton("Elimina oggetto", kind: .destructive, confirmationTitle: "Eliminare «\(item.name)»?", action: delete)
                    .accessibilityIdentifier("deleteItem")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Modifica") { editor = ItemEditor(mode: .edit(item)) }
                    .tint(SbuTheme.ink)
                    .accessibilityIdentifier("editItem")
            }
        }
        .sheet(item: $editor) { editor in
            ItemFormSheet(editor: editor)
        }
        .sheet(item: $moving) { entry in
            MoveSheet(entry: entry)
        }
        .onDisappear(perform: deleteIfLeaving)
        .onAppear(perform: closeIfNew)
    }

    /// How many, on its paper: the one figure of this screen.
    private var figure: some View {
        SteadyFigure { isPlaceholder in
            SbuFigure(
                value: item.quantity.formatted(),
                fullStop: isPlaceholder ? .absent : .set,
                context: valueLine.map { Text($0) },
                accessibilityLabel: accessibilityLabel
            )
            .sbuClosure($isClosing, word: "Aggiunto")
            .accessibilityIdentifier("quantity")
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        // On the row's own content, so the grid and the figure's baseline scroll together.
        .sbuPaper(grid: true)
        // The paper reaches past the row into the safe area: keep the grid inside it.
        .clipped()
    }

    private var accessibilityLabel: Text {
        if let valueLine {
            Text("Quantità: \(item.quantity), \(Text(valueLine))")
        } else {
            Text("Quantità: \(item.quantity)")
        }
    }

    private var path: String {
        let tree = InventoryTree(folders: folders.map(\.node), items: [])
        return FolderPath.text(tree.path(of: item.folder?.uuid), root: String(localized: "Inventario"))
    }

    private var valueLine: LocalizedStringKey? {
        guard let price = item.unitPrice, let total = item.totalValue else { return nil }
        let each = price.formatted(InventoryCurrency.format)
        let all = total.formatted(InventoryCurrency.format)
        return item.quantity == 1 ? "\(each)" : "\(each) l'uno · \(all) in tutto"
    }

    private var quantity: Binding<Int> {
        Binding { item.quantity } set: { InventoryActions.setQuantity($0, of: item, context: context) }
    }

    /// Goes back first and deletes once the screen is gone, so nothing draws an item that no longer exists.
    private func delete() {
        isDeleting = true
        dismiss()
    }

    private func closeIfNew() {
        guard isNew, !hasClosed else { return }
        hasClosed = true
        isClosing = true
    }

    private func deleteIfLeaving() {
        guard isDeleting else { return }
        InventoryActions.delete(item, context: context)
    }
}

#Preview("Light") {
    NavigationStack {
        ItemDetailView(item: try! ModelContainer.preview.mainContext.fetch(FetchDescriptor<Item>()).first!)
    }
    .modelContainer(.preview)
    .environment(\.sbuAccent, .inventory)
}

#Preview("Dark") {
    NavigationStack {
        ItemDetailView(item: try! ModelContainer.preview.mainContext.fetch(FetchDescriptor<Item>()).first!)
    }
    .modelContainer(.preview)
    .environment(\.sbuAccent, .inventory)
    .preferredColorScheme(.dark)
}
