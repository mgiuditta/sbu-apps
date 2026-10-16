import SbuKit
import SwiftUI

/// Settings section for the list: whether devices without a name are shown.
struct ListSection: View {
    @Bindable var model: ScanModel

    var body: some View {
        Section {
            Toggle("Mostra dispositivi senza nome", isOn: $model.showsUnnamed)
        } header: {
            Text("Lista")
        } footer: {
            Text("Spesso sono telefoni, computer e accessori dei vicini. Mostrali se quello che cerchi non ha un nome.")
        }
    }
}

#Preview("Light") {
    List {
        ListSection(model: ScanModel(scanner: FixedScanner()))
    }
}

#Preview("Dark") {
    List {
        ListSection(model: ScanModel(scanner: FixedScanner()))
    }
    .preferredColorScheme(.dark)
}
