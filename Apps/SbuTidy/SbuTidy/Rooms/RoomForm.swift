import SbuKit
import SwiftData
import SwiftUI

/// New or edited room: its kind, its name and, when new, its base chores.
struct RoomForm: View {
    let room: Room?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var draft: RoomDraft
    @FocusState private var isNameFocused: Bool

    init(room: Room?) {
        self.room = room
        _draft = State(initialValue: room.map { RoomDraft(kind: $0.kind, name: $0.name) } ?? RoomDraft())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    RoomKindPicker(selection: kind)
                    TextField("Nome", text: $draft.name)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                        .onSubmit(save)
                        .accessibilityIdentifier("roomName")
                }
                .listRowBackground(SbuTheme.surfaceRaised)
                if room == nil {
                    Section {
                        Toggle("Aggiungi le attività di base", isOn: $draft.addsBaseChores)
                    } footer: {
                        Text(baseFooter)
                    }
                    .listRowBackground(SbuTheme.surfaceRaised)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(room == nil ? "Nuova stanza" : "Modifica stanza")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(room == nil ? "Aggiungi" : "Salva", action: save)
                        .disabled(!draft.isValid)
                        .accessibilityIdentifier("saveRoom")
                }
            }
        }
    }

    private var kind: Binding<RoomKind> {
        Binding { draft.kind } set: { draft.select($0) }
    }

    private var baseFooter: LocalizedStringKey {
        let names = draft.kind.basePresets.map { String(localized: $0.name) }
        if names.isEmpty { return "Per questo tipo di stanza non ci sono attività di base: aggiungile dai suggerimenti." }
        return "\(names.formatted(.list(type: .and)))."
    }

    private func cancel() {
        dismiss()
    }

    private func save() {
        guard draft.isValid else { return }
        if let room {
            Home.update(room, with: draft)
        } else {
            Home.addRoom(draft, in: modelContext)
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    RoomForm(room: nil)
        .modelContainer(.preview)
        .environment(\.sbuAccent, .tidy)
}

#Preview("Dark") {
    RoomForm(room: nil)
        .modelContainer(.preview)
        .environment(\.sbuAccent, .tidy)
        .preferredColorScheme(.dark)
}
