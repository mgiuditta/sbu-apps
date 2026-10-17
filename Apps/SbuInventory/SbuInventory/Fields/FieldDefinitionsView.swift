import SbuKit
import SwiftData
import SwiftUI

/// The custom fields every item has: add, rename, reorder, delete.
struct FieldDefinitionsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FieldDefinition.order) private var definitions: [FieldDefinition]
    @State private var editing: FieldEditing?
    @State private var deleting: FieldDefinition?

    var body: some View {
        List {
            Section {
                ForEach(definitions) { definition in
                    Button {
                        editing = .rename(definition)
                    } label: {
                        LabeledContent {
                            Text(definition.kind.title)
                        } label: {
                            Text(definition.name)
                                .foregroundStyle(SbuTheme.ink)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Elimina", systemImage: "trash") { deleting = definition }
                            .tint(SbuTheme.danger)
                    }
                }
                .onMove(perform: move)
                Button("Aggiungi campo") { editing = .create }
                    .accessibilityIdentifier("addField")
            } footer: {
                Text("Ogni oggetto ha questi campi; quelli vuoti non compaiono. Tocca un campo per rinominarlo, tienilo premuto per spostarlo.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle("Campi personalizzati")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editing) { editing in
            FieldFormSheet(editing: editing, nextOrder: (definitions.map(\.order).max() ?? -1) + 1)
        }
        .alert(Text("Eliminare il campo «\(deleting?.name ?? "")»?"), isPresented: isDeleting, presenting: deleting) { definition in
            Button("Elimina", role: .destructive) { delete(definition) }
            Button("Annulla", role: .cancel) {}
        } message: { definition in
            Text("Il valore va via da ^[\(definition.values?.count ?? 0) oggetto](inflect: true).")
        }
    }

    private var isDeleting: Binding<Bool> {
        Binding { deleting != nil } set: { if !$0 { deleting = nil } }
    }

    private func move(from source: IndexSet, to destination: Int) {
        var ordered = definitions
        ordered.move(fromOffsets: source, toOffset: destination)
        for (order, definition) in ordered.enumerated() {
            definition.order = order
        }
        InventoryActions.save(context)
    }

    private func delete(_ definition: FieldDefinition) {
        let items = (definition.values ?? []).compactMap(\.item)
        context.delete(definition)
        for item in items {
            item.refreshSearchKey()
        }
        InventoryActions.save(context)
    }
}

#Preview("Light") {
    NavigationStack {
        FieldDefinitionsView()
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack {
        FieldDefinitionsView()
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
