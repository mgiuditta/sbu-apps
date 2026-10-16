import SbuKit
import SwiftData
import SwiftUI

/// Medisafe's "Farmaci" and its profiles in one list: how many medicines you look after, then
/// each person with theirs; add, rename or remove people here.
struct MedicinesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Person.order), SortDescriptor(\Person.createdAt)]) private var people: [Person]
    @Query private var medicines: [Medicine]
    @State private var newMedicineFor: Person?
    @State private var editingPerson: Person?
    @State private var isAddingPerson = false

    var body: some View {
        List {
            Section {
                SbuStat("Farmaci", value: medicines.count, format: .number, context: context)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .accessibilityIdentifier("medicinesFigure")
            }
            ForEach(people) { person in
                PersonMedicinesSection(person: person, edit: { editingPerson = person }, add: { newMedicineFor = person })
            }
            Section {
                Button("Aggiungi persona", systemImage: "person.badge.plus", action: addPerson)
                    .accessibilityIdentifier("addPerson")
            } footer: {
                Text("Ognuno con i suoi farmaci e il suo storico, su questo iPhone. Nessun account.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Farmaci")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Destination.report) {
                    Label("Rapporto per il medico", systemImage: "doc.text")
                }
                .tint(SbuTheme.ink)
                .accessibilityIdentifier("report")
            }
        }
        .sheet(item: $newMedicineFor) { person in
            MedicineEditor(person: person, medicine: nil)
        }
        .sheet(item: $editingPerson) { person in
            PersonForm(person: person, canDelete: people.count > 1)
        }
        .sheet(isPresented: $isAddingPerson) {
            PersonForm(person: nil, canDelete: false)
        }
    }

    private var context: LocalizedStringKey {
        people.count == 1 ? "per una persona" : "per \(people.count) persone"
    }

    private func addPerson() {
        isAddingPerson = true
    }
}

#Preview("Light") {
    NavigationStack {
        MedicinesView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentMeds)
}

#Preview("Dark") {
    NavigationStack {
        MedicinesView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .tint(SbuTheme.accentMeds)
    .preferredColorScheme(.dark)
}
