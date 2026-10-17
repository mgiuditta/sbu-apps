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
                SbuFigure(
                    value: medicines.count.formatted(),
                    fullStop: medicines.isEmpty ? .waiting : .set,
                    context: Text(context),
                    accessibilityLabel: Text("Farmaci: \(medicines.count). \(Text(context))")
                )
                .accessibilityIdentifier("medicinesFigure")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SbuTheme.space4)
                // Plain paper, not the grid: the figure sits above List rows.
                .sbuPaper(grid: false)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
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
        .background(SbuTheme.paper)
        .navigationTitle("Farmaci")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Destination.report) {
                    Label("Rapporto per il medico", systemImage: "doc.text")
                }
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
        people.count == 1 ? "farmaci · per una persona" : "farmaci · per \(people.count) persone"
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
    .environment(\.sbuAccent, .meds)
}

#Preview("Dark") {
    NavigationStack {
        MedicinesView()
    }
    .modelContainer(.preview)
    .environment(Clock())
    .environment(\.sbuAccent, .meds)
    .preferredColorScheme(.dark)
}
