import SbuKit
import SwiftUI

/// One person in the medicines list: their name with "Modifica", their medicines, and "Aggiungi farmaco".
struct PersonMedicinesSection: View {
    let person: Person
    let edit: () -> Void
    let add: () -> Void

    var body: some View {
        Section {
            ForEach(person.medicineList) { medicine in
                NavigationLink(value: medicine) {
                    MedicineRow(medicine: medicine.snapshot)
                }
                .accessibilityIdentifier("medicine")
            }
            Button("Aggiungi farmaco", systemImage: "plus", action: add)
                .accessibilityIdentifier("addMedicineFor")
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text(person.name)
                Spacer()
                Button("Modifica", action: edit)
                    .font(SbuTheme.subheadline.weight(.semibold))
                    .textCase(nil)
                    .frame(minHeight: SbuTheme.controlRoundSm)
                    .contentShape(.rect)
                    .accessibilityLabel(Text("Modifica \(person.name)"))
                    .accessibilityIdentifier("editPerson")
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
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
