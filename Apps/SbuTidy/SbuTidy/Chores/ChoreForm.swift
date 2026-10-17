import SbuKit
import SwiftData
import SwiftUI

/// New or edited chore, as Tody's: a name or a suggestion for the room, the frequency, the effort,
/// and for a new one when you last did it.
struct ChoreForm: View {
    private enum Field: Hashable {
        case name
        case notes
    }

    let room: Room
    let chore: Chore?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ChoreDraft
    @FocusState private var focus: Field?

    init(room: Room, chore: Chore?) {
        self.room = room
        self.chore = chore
        _draft = State(initialValue: chore.map(ChoreDraft.init(chore:)) ?? ChoreDraft())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $draft.name)
                        .focused($focus, equals: .name)
                        .submitLabel(.done)
                        .accessibilityIdentifier("choreName")
                    if chore == nil {
                        NavigationLink {
                            PresetPicker(kind: room.kind, existing: room.choreList.map(\.name), pick: pick)
                        } label: {
                            Text("Scegli dai suggerimenti")
                        }
                        .accessibilityIdentifier("presets")
                    }
                }
                FrequencySection(value: $draft.frequencyValue, unit: unit)
                Section("Sforzo") {
                    Picker("Sforzo", selection: $draft.effort) {
                        ForEach(Effort.allCases, id: \.self) { Text($0.name).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                Section {
                    Toggle("Una tantum", isOn: $draft.isOneOff)
                } footer: {
                    Text("Sparisce quando la segni come fatta.")
                }
                if chore == nil {
                    Section {
                        DatePicker("Ultima volta", selection: $draft.lastDone, in: ...Date.now, displayedComponents: .date)
                    } footer: {
                        Text("Da qui parte lo sporco. Se l'hai appena fatta, lascia oggi.")
                    }
                }
                Section("Note") {
                    TextField("Prodotti, attrezzi, trucchi", text: $draft.notes, axis: .vertical)
                        .focused($focus, equals: .notes)
                        .lineLimit(3...8)
                }
                if let chore {
                    Section {
                        SbuButton("Elimina attività", kind: .destructive, confirmationTitle: "Eliminare “\(chore.name)”?") {
                            delete(chore)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(chore == nil ? "Nuova attività" : "Modifica attività")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(chore == nil ? "Aggiungi" : "Salva", action: save)
                        .disabled(!draft.isValid)
                        .accessibilityIdentifier("saveChore")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fine", action: endEditing)
                }
            }
        }
    }

    private var unit: Binding<FrequencyUnit> {
        Binding { draft.frequencyUnit } set: { draft.select($0) }
    }

    private func pick(_ preset: ChorePreset) {
        let lastDone = draft.lastDone
        let notes = draft.notes
        draft = ChoreDraft(preset: preset, lastDone: lastDone)
        draft.notes = notes
    }

    private func endEditing() {
        focus = nil
    }

    private func cancel() {
        dismiss()
    }

    private func save() {
        guard draft.isValid else { return }
        if let chore {
            Home.update(chore, with: draft)
        } else {
            Home.addChore(draft, to: room, in: modelContext)
        }
        try? modelContext.save()
        dismiss()
    }

    private func delete(_ chore: Chore) {
        dismiss()
        Home.delete(chore, in: modelContext)
        try? modelContext.save()
    }
}

#Preview("Light") {
    ChoreFormPreview()
}

#Preview("Dark") {
    ChoreFormPreview()
        .preferredColorScheme(.dark)
}

private struct ChoreFormPreview: View {
    @Query private var rooms: [Room]

    var body: some View {
        Group {
            if let room = rooms.first {
                ChoreForm(room: room, chore: nil)
            }
        }
        .modelContainer(.preview)
        .environment(\.sbuAccent, .tidy)
    }
}
