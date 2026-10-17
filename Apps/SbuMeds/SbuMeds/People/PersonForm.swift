import SbuKit
import SwiftData
import SwiftUI

/// A new person, or a person renamed or removed with their medicines and history.
struct PersonForm: View {
    let person: Person?
    /// The last person stays: the app always has someone to show.
    let canDelete: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @FocusState private var isFocused: Bool

    init(person: Person?, canDelete: Bool) {
        self.person = person
        self.canDelete = canDelete
        _name = State(initialValue: person?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name)
                        .focused($isFocused)
                        .textContentType(.name)
                        .submitLabel(.done)
                        .onSubmit(save)
                        .accessibilityIdentifier("personName")
                } footer: {
                    Text("Un figlio, un genitore, chi assisti: i suoi farmaci restano separati dai tuoi.")
                }
                if let person, canDelete {
                    Section {
                        SbuButton("Elimina persona", kind: .destructive, confirmationTitle: "Eliminare “\(person.name)” con i suoi farmaci e il suo storico?") {
                            delete(person)
                        }
                        .accessibilityIdentifier("deletePerson")
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle(person == nil ? "Nuova persona" : "Modifica persona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(person == nil ? "Aggiungi" : "Salva", action: save)
                        .disabled(Cabinet.cleanName(name).isEmpty)
                        .accessibilityIdentifier("savePerson")
                }
            }
            .onAppear { isFocused = person == nil }
        }
    }

    private func cancel() {
        dismiss()
    }

    private func save() {
        guard !Cabinet.cleanName(name).isEmpty else { return }
        if let person {
            Cabinet.rename(person, to: name)
        } else {
            Cabinet.addPerson(named: name, in: modelContext)
        }
        try? modelContext.save()
        dismiss()
    }

    private func delete(_ person: Person) {
        dismiss()
        Cabinet.delete(person, in: modelContext)
        try? modelContext.save()
    }
}

#Preview("Light") {
    PersonForm(person: nil, canDelete: false)
        .modelContainer(.preview)
        .environment(\.sbuAccent, .meds)
}

#Preview("Dark") {
    PersonForm(person: nil, canDelete: false)
        .modelContainer(.preview)
        .environment(\.sbuAccent, .meds)
        .preferredColorScheme(.dark)
}
