import SbuKit
import SwiftData
import SwiftUI

/// Adds an item or edits one: photos, name, how many, where, value, fields, tags, label, minimum, notes.
/// Nothing changes until Salva; with changes made, a swipe down doesn't throw them away.
struct ItemFormSheet: View {
    let editor: ItemEditor
    /// Called with the item once saved.
    var saved: (Item) -> Void = { _ in }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FieldDefinition.order) private var definitions: [FieldDefinition]
    @Query private var items: [Item]
    @Query private var folders: [Folder]
    @State private var draft: ItemDraft
    private let original: ItemDraft
    @FocusState private var isNameFocused: Bool

    init(editor: ItemEditor, saved: @escaping (Item) -> Void = { _ in }) {
        self.editor = editor
        self.saved = saved
        let draft = switch editor.mode {
        case let .new(folder, code): ItemDraft(folder: folder, code: code)
        case let .edit(item): ItemDraft(item: item)
        }
        _draft = State(initialValue: draft)
        original = draft
    }

    var body: some View {
        NavigationStack {
            Form {
                PhotosSection(photos: $draft.photos)
                    .listRowBackground(SbuTheme.surfaceRaised)
                Section {
                    TextField("Nome", text: $draft.name)
                        .font(SbuTheme.headline)
                        .focused($isNameFocused)
                        .accessibilityIdentifier("itemName")
                    QuantityField(title: "Quantità", value: $draft.quantity)
                    NavigationLink {
                        FolderChoice(selection: $draft.folder)
                    } label: {
                        LabeledContent("Posizione", value: path)
                    }
                    .accessibilityIdentifier("itemFolder")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
                Section {
                    LabeledContent("Prezzo di uno") {
                        TextField("Prezzo di uno", value: $draft.unitPrice, format: InventoryCurrency.format, prompt: Text(Decimal.zero, format: InventoryCurrency.format))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityIdentifier("itemPrice")
                    }
                    OptionalDateRow(title: String(localized: "Data d'acquisto"), date: $draft.purchaseDate)
                } header: {
                    Text("Valore")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
                Section {
                    ForEach(definitions) { definition in
                        FieldEntryRow(definition: definition, entry: fieldBinding(definition))
                    }
                    NavigationLink("Gestisci i campi") {
                        FieldDefinitionsView()
                    }
                } header: {
                    Text("Campi")
                } footer: {
                    if definitions.isEmpty {
                        Text("Aggiungi campi come Numero di serie o Garanzia fino al: li trovi in ogni oggetto.")
                    }
                }
                .listRowBackground(SbuTheme.surfaceRaised)
                TagsSection(tags: $draft.tags, allTags: items.flatMap(\.tags))
                    .listRowBackground(SbuTheme.surfaceRaised)
                LabelSection(code: $draft.code, item: editedItem)
                    .listRowBackground(SbuTheme.surfaceRaised)
                Section {
                    Toggle("Avvisa quando ne restano pochi", isOn: hasMinimum)
                        .accessibilityIdentifier("hasMinimum")
                    if draft.minimumQuantity != nil {
                        QuantityField(title: "Quantità minima", value: minimum)
                    }
                } header: {
                    Text("Da ricomprare")
                } footer: {
                    Text("Arrivato alla quantità minima, l'oggetto è da ricomprare.")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
                Section {
                    TextField("Note", text: $draft.notes, axis: .vertical)
                        .lineLimit(3...)
                } header: {
                    Text("Note")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(SbuTheme.surface)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                        .disabled(!draft.canSave)
                        .accessibilityIdentifier("saveItem")
                }
            }
            .interactiveDismissDisabled(draft != original)
            .onAppear {
                if case .new = editor.mode { isNameFocused = true }
            }
        }
    }

    private var title: LocalizedStringKey {
        if case .edit = editor.mode { "Modifica oggetto" } else { "Nuovo oggetto" }
    }

    private var editedItem: Item? {
        if case let .edit(item) = editor.mode { item } else { nil }
    }

    private var path: String {
        let tree = InventoryTree(folders: folders.map(\.node), items: [])
        return FolderPath.text(tree.path(of: draft.folder?.uuid), root: String(localized: "Inventario"))
    }

    private var hasMinimum: Binding<Bool> {
        Binding { draft.minimumQuantity != nil } set: { draft.minimumQuantity = $0 ? max(draft.minimumQuantity ?? 1, 0) : nil }
    }

    private var minimum: Binding<Int> {
        Binding { draft.minimumQuantity ?? 1 } set: { draft.minimumQuantity = $0 }
    }

    private func fieldBinding(_ definition: FieldDefinition) -> Binding<FieldEntry> {
        Binding { draft.fields[definition.uuid] ?? FieldEntry() } set: { draft.fields[definition.uuid] = $0 }
    }

    private func save() {
        guard draft.canSave else { return }
        let item: Item
        switch editor.mode {
        case .new:
            item = Item(name: draft.trimmedName)
            context.insert(item)
        case let .edit(existing):
            item = existing
        }
        draft.apply(to: item, definitions: definitions, context: context)
        InventoryActions.save(context)
        dismiss()
        saved(item)
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    ItemFormSheet(editor: ItemEditor(mode: .new(folder: nil, code: nil)))
        .modelContainer(.preview)
        .tint(SbuTheme.accentInventory)
}

#Preview("Dark") {
    ItemFormSheet(editor: ItemEditor(mode: .new(folder: nil, code: "8001234567890")))
        .modelContainer(.preview)
        .tint(SbuTheme.accentInventory)
        .preferredColorScheme(.dark)
}
