import SbuKit
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Settings → your data, always yours: export everything as CSV, or as an archive with the photos;
/// import a file exported from here or from a spreadsheet.
struct DataSection: View {
    @Environment(\.modelContext) private var context
    @Query private var items: [Item]
    @Query private var folders: [Folder]
    @State private var isImporting = false
    @State private var pending: ImportFile?
    @State private var failure: ImportFile.Failure?
    @State private var result: ImportResult?

    var body: some View {
        let isEmpty = items.isEmpty && folders.isEmpty
        Section {
            // Words only: beside a symbol the audit finds the title clipped at larger text (as in Sbu Habits).
            ShareLink(item: InventoryCSVFile(container: context.container), preview: SharePreview(Text("Inventario CSV"))) {
                Text("Esporta CSV")
            }
            .disabled(isEmpty)
            .accessibilityIdentifier("exportCSV")
            ShareLink(item: InventoryArchiveFile(container: context.container), preview: SharePreview(Text("Inventario con foto"))) {
                Text("Esporta archivio con foto")
            }
            .disabled(isEmpty)
            .accessibilityIdentifier("exportArchive")
            Button("Importa") { isImporting = true }
                .accessibilityIdentifier("import")
        } header: {
            Text("Dati")
        } footer: {
            Text("Esporta crea un file con tutto l'inventario, che salvi dove vuoi tu; l'archivio ha anche le foto. Importa legge un file esportato da qui o da un foglio di calcolo: gli oggetti già presenti restano come sono.")
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.commaSeparatedText, .plainText, .zip], onCompletion: read)
        .alert(Text("Importare ^[\(pending?.itemCount ?? 0) oggetto](inflect: true)?"), isPresented: isConfirming, presenting: pending) { file in
            Button("Importa") { apply(file) }
            Button("Annulla", role: .cancel) {}
        } message: { _ in
            Text("Le cartelle che mancano vengono create. Gli oggetti già presenti restano come sono.")
        }
        .alert(Text("Importazione non riuscita"), isPresented: hasFailure, presenting: failure) { _ in
            Button("OK", role: .cancel) {}
        } message: { failure in
            Text(message(for: failure))
        }
        .alert(Text("Importazione completata"), isPresented: hasResult, presenting: result) { _ in
            Button("OK", role: .cancel) {}
        } message: { result in
            Text(summary(of: result))
        }
    }

    private var isConfirming: Binding<Bool> {
        Binding { pending != nil } set: { if !$0 { pending = nil } }
    }

    private var hasFailure: Binding<Bool> {
        Binding { failure != nil } set: { if !$0 { failure = nil } }
    }

    private var hasResult: Binding<Bool> {
        Binding { result != nil } set: { if !$0 { result = nil } }
    }

    private func read(_ picked: Result<URL, any Error>) {
        guard let url = try? picked.get() else { return }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            failure = .unreadable
            return
        }
        do {
            let file = try ImportFile(data: data, calendar: .current)
            if file.rows.isEmpty { failure = .unreadable } else { pending = file }
        } catch {
            failure = error
        }
    }

    private func apply(_ file: ImportFile) {
        result = InventoryImport.apply(file, into: context)
    }

    private func message(for failure: ImportFile.Failure) -> LocalizedStringKey {
        switch failure {
        case .unreadable: "Il file è vuoto o non si legge."
        case .noCSV: "Nell'archivio non c'è un file CSV."
        case .noNameColumn: "Nel file non trovo la colonna con i nomi degli oggetti."
        case .tooLarge: "L'archivio è troppo grande o danneggiato."
        }
    }

    private func summary(of result: ImportResult) -> LocalizedStringKey {
        result.skipped == 0
            ? "^[\(result.added) oggetto importato](inflect: true)."
            : "^[\(result.added) oggetto importato](inflect: true), ^[\(result.skipped) già presente](inflect: true)."
    }
}

#Preview("Light") {
    Form {
        DataSection()
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    Form {
        DataSection()
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
