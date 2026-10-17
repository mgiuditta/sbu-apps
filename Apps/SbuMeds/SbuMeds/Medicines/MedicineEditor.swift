import SbuKit
import SwiftData
import SwiftUI

/// New or edited medicine, Medisafe's wizard on one page: name, form, strength, how often and
/// when, for how long, the stock. No drug database and no dose advice: you write what the
/// doctor or the leaflet says.
struct MedicineEditor: View {
    private enum Field: Hashable {
        case name
        case strength
        case notes
    }

    let person: Person
    let medicine: Medicine?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MedicineDraft
    @FocusState private var focus: Field?

    init(person: Person, medicine: Medicine?, calendar: Calendar = .current) {
        self.person = person
        self.medicine = medicine
        let today = Day(.now, calendar: calendar)
        _draft = State(initialValue: medicine.map { MedicineDraft(medicine: $0.snapshot, calendar: calendar) } ?? MedicineDraft(today: today, calendar: calendar))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $draft.name)
                        .focused($focus, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focus = .strength }
                        .accessibilityIdentifier("medicineName")
                    TextField("Dosaggio, come sulla confezione", text: $draft.strength)
                        .focused($focus, equals: .strength)
                        .submitLabel(.done)
                    Picker("Forma", selection: $draft.form) {
                        ForEach(MedicineForm.allCases) { form in
                            Label { Text(form.name) } icon: { Image(systemName: form.systemImage) }.tag(form)
                        }
                    }
                } footer: {
                    Text("Per \(person.name)")
                }
                FrequencySection(draft: $draft)
                DoseTimesSection(draft: $draft)
                DurationSection(draft: $draft)
                StockSection(draft: $draft)
                Section("Note") {
                    TextField("Con il cibo, prima di dormire…", text: $draft.notes, axis: .vertical)
                        .focused($focus, equals: .notes)
                        .lineLimit(2...6)
                }
                if let medicine {
                    Section {
                        SbuButton("Elimina farmaco", kind: .destructive, confirmationTitle: "Eliminare “\(medicine.name)” e il suo storico?") {
                            delete(medicine)
                        }
                        .accessibilityIdentifier("deleteMedicine")
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(medicine == nil ? "Nuovo farmaco" : "Modifica farmaco")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(medicine == nil ? "Aggiungi" : "Salva", action: save)
                        .disabled(!draft.isValid)
                        .accessibilityIdentifier("saveMedicine")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fine", action: endEditing)
                }
            }
        }
    }

    private func endEditing() {
        focus = nil
    }

    private func cancel() {
        dismiss()
    }

    private func save() {
        guard draft.isValid else { return }
        if let medicine {
            Cabinet.update(medicine, with: draft)
        } else {
            Cabinet.addMedicine(draft, for: person, in: modelContext)
        }
        try? modelContext.save()
        dismiss()
    }

    private func delete(_ medicine: Medicine) {
        dismiss()
        Cabinet.delete(medicine, in: modelContext)
        try? modelContext.save()
    }
}

#Preview("Light") {
    MedicineEditorPreview()
}

#Preview("Dark") {
    MedicineEditorPreview()
        .preferredColorScheme(.dark)
}

private struct MedicineEditorPreview: View {
    @Query private var people: [Person]

    var body: some View {
        Group {
            if let person = people.first {
                MedicineEditor(person: person, medicine: nil)
            }
        }
        .modelContainer(.preview)
        .environment(\.sbuAccent, .meds)
    }
}
