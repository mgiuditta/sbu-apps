import SbuKit
import SwiftUI

/// How four universities compute the base, as examples to copy into Settings: check your own course's regulation.
struct FormulaHelpView: View {
    var body: some View {
        List {
            Section {
                Text("La base di laurea è la media pesata sui CFU, convertita in centodecimi. Ogni ateneo, e spesso ogni corso, cambia qualcosa: il valore della lode, i voti esclusi, i bonus, l'arrotondamento. Controlla il regolamento del tuo corso.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
            }
            ForEach(UniversityExample.all) { example in
                Section {
                    Text(example.rule)
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                    Text(example.settings)
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                } header: {
                    Text(example.name)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle("Esempi di calcolo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack {
        FormulaHelpView()
    }
}

#Preview("Dark") {
    NavigationStack {
        FormulaHelpView()
    }
    .preferredColorScheme(.dark)
}
