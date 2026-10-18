import SbuKit
import SwiftUI

/// Settings: the Record, and the way to forget it.
struct RecordSection: View {
    let store: GameStore

    var body: some View {
        Section {
            LabeledContent("Record") {
                Text(store.record, format: .number)
                    .monospacedDigit()
            }
            SbuButton("Azzera il record", kind: .destructive, confirmationTitle: "Azzerare il record?", action: store.resetRecord)
                .listRowInsets(EdgeInsets())
                .disabled(store.record == 0)
        } footer: {
            Text("Il record resta solo su questo iPhone. Niente classifiche, niente account.")
        }
    }
}

#Preview("Light") {
    List { RecordSection(store: GameStore(defaults: UserDefaults(suiteName: "preview.record")!)) }
}

#Preview("Dark") {
    List { RecordSection(store: GameStore(defaults: UserDefaults(suiteName: "preview.record")!)) }
        .preferredColorScheme(.dark)
}
