import SbuKit
import SwiftUI

/// Impostazioni: Esporta writes the habits and their history to a file you keep where you want.
struct DataSection: View {
    let model: HabitsModel

    var body: some View {
        let export = HabitsExport(file: model.file, date: .now)
        Section {
            ShareLink("Esporta", item: export, preview: SharePreview(export.fileName))
                // An unreadable file comes from a newer app: an empty export would mislead.
                .disabled(model.isUnreadable)
        } header: {
            Text("Dati")
        } footer: {
            Text("Esporta crea un file con le abitudini e lo storico. Lo salvi dove vuoi tu.")
        }
    }
}

#Preview("Light") {
    Form {
        DataSection(model: .preview)
    }
    .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    Form {
        DataSection(model: .preview)
    }
    .tint(SbuTheme.accentHabits)
    .preferredColorScheme(.dark)
}
