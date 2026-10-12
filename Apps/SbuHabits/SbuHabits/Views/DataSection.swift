import SbuKit
import SwiftUI

/// Impostazioni: Esporta writes the habits and their history to a file you keep where you want;
/// Importa checks such a file, shows what it contains and replaces the current data with it.
struct DataSection: View {
    let model: HabitsModel

    @State private var isImporting = false
    @State private var candidate: HabitsImport?
    @State private var failure: HabitsImport.Failure?

    var body: some View {
        let export = HabitsExport(file: model.file, date: .now)
        Section {
            ShareLink("Esporta", item: export, preview: SharePreview(export.fileName))

            Button("Importa", systemImage: "square.and.arrow.down", action: chooseFile)
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], onCompletion: check)
                .sheet(item: $candidate) { candidate in
                    ImportReviewView(model: model, candidate: candidate)
                }
                .importFailureAlert($failure)
        } header: {
            Text("Dati")
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
