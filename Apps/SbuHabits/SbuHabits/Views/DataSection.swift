import SbuKit
import SwiftUI

/// Impostazioni: Sincronizza con iCloud, then Esporta, which writes the habits and their history to a file you keep where you want;
/// Importa checks such a file, shows what it contains and replaces the current data with it.
struct DataSection: View {
    let model: HabitsModel
    let sync: HabitsSync

    @State private var isImporting = false
    @State private var candidate: HabitsImport?
    @State private var failure: HabitsImport.Failure?

    var body: some View {
        let export = HabitsExport(file: model.file, date: .now)
        ICloudSyncSection(sync: sync)
            // An unreadable file comes from a newer app: merging it could lose what it holds.
            .disabled(model.isUnreadable)
        Section {
            // Words only: the audit finds Importa's title clipped at larger text beside its symbol.
            ShareLink(item: export, preview: SharePreview(export.fileName)) {
                Text("Esporta")
            }

            Button("Importa", action: chooseFile)
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], onCompletion: check)
                .sheet(item: $candidate) { candidate in
                    ImportReviewView(model: model, candidate: candidate)
                }
                .importFailureAlert($failure)
        } footer: {
            Text("Esporta crea un file con le abitudini e lo storico. Lo salvi dove vuoi tu. Importa sostituisce i dati attuali con quelli di un file.")
        }
        // An unreadable file comes from a newer app: an empty export would mislead, and an
        // import would overwrite data this version cannot read.
        .disabled(model.isUnreadable)
    }

    private func chooseFile() {
        isImporting = true
    }

    private func check(_ result: Result<URL, any Error>) {
        do {
            candidate = try HabitsImport(contentsOf: result.get())
        } catch let error as HabitsImport.Failure {
            failure = error
        } catch {
            failure = .unreadable
        }
    }
}

#Preview("Light") {
    Form {
        DataSection(model: .preview, sync: .preview(model: .preview))
    }
    .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    Form {
        DataSection(model: .preview, sync: .preview(model: .preview))
    }
    .tint(SbuTheme.accentHabits)
    .preferredColorScheme(.dark)
}
