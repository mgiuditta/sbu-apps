import SbuKit
import SwiftUI

/// Settings: the Record of each difficulty, and the way to forget them.
struct RecordsSection: View {
    let store: GameStore

    var body: some View {
        Section {
            ForEach(Difficulty.allCases) { difficulty in
                LabeledContent {
                    Text(store.record(for: difficulty), format: .number)
                        .monospacedDigit()
                } label: {
                    Text(difficulty.name)
                }
            }
            SbuButton("Azzera i record", kind: .destructive, confirmationTitle: "Azzerare i record?", action: store.resetRecords)
                .listRowInsets(EdgeInsets())
                .disabled(store.records.isEmpty)
        } header: {
            Text("Record")
        } footer: {
            Text("Il record di una difficoltà è il punteggio più alto di una partita risolta. Resta solo su questo iPhone.")
        }
    }
}

#Preview("Light") {
    List { RecordsSection(store: GameStore(defaults: UserDefaults(suiteName: "preview.records")!)) }
}

#Preview("Dark") {
    List { RecordsSection(store: GameStore(defaults: UserDefaults(suiteName: "preview.records")!)) }
        .preferredColorScheme(.dark)
}
