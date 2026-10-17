import SbuKit
import SwiftData
import SwiftUI

/// Names a custom field and, for a new one, chooses what it holds. The kind stays once created,
/// so the values already typed never change meaning.
struct FieldFormSheet: View {
    let editing: FieldEditing
    let nextOrder: Int

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var kind = FieldKind.text
    @FocusState private var isNameFocused: Bool

    init(editing: FieldEditing, nextOrder: Int) {
        self.editing = editing
        self.nextOrder = nextOrder
        if case let .rename(definition) = editing {
            _name = State(initialValue: definition.name)
            _kind = State(initialValue: definition.kind)
        } else {
            _name = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome del campo", text: $name)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                        .onSubmit(save)
                        .accessibilityIdentifier("fieldName")
                    if case .create = editing {
                        Picker("Tipo", selection: $kind) {
                            ForEach(FieldKind.allCases, id: \.self) { kind in
                                Text(kind.title).tag(kind)
                            }
                        }
                    } else {
                        LabeledContent("Tipo") {
                            Text(kind.title)
                        }
                    }
                } footer: {
                    Text("Per esempio Numero di serie (testo), Garanzia fino al (data), Riparazione (importo).")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle(isCreating ? "Nuovo campo" : "Rinomina campo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isCreating ? "Aggiungi" : "Salva", action: save)
                        .disabled(trimmed.isEmpty)
                        .accessibilityIdentifier("saveField")
                }
            }
            .onAppear { isNameFocused = true }
        }
    }

    private var isCreating: Bool {
        if case .create = editing { true } else { false }
    }

    private var trimmed: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        guard !trimmed.isEmpty else { return }
        switch editing {
        case .create:
            context.insert(FieldDefinition(name: trimmed, kind: kind, order: nextOrder))
        case let .rename(definition):
            definition.name = trimmed
        }
        InventoryActions.save(context)
        dismiss()
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    FieldFormSheet(editing: .create, nextOrder: 0)
        .modelContainer(.preview)
}

#Preview("Dark") {
    FieldFormSheet(editing: .create, nextOrder: 0)
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
