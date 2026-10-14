import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Settings → export every subscription as CSV, or import a CSV after reviewing it row by row.
struct DataSection: View {
    let currency: CurrencySettings

    @Query private var subscriptions: [Subscription]
    @State private var isImporting = false
    @State private var file: CSVImport?
    @State private var failure: CSVImport.Failure?

    var body: some View {
        let export = CSVExport(subscriptions)
        Section {
            // Words only: beside a symbol the audit finds the title clipped at larger text (as in Sbu Habits).
            ShareLink(item: export, preview: SharePreview(export.fileName)) {
                Text("Esporta CSV")
            }
            .disabled(subscriptions.isEmpty)
            Button("Importa CSV") { isImporting = true }
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.commaSeparatedText, .plainText], onCompletion: read)
                .sheet(item: $file) { file in
                    CSVReviewView(file: file, existing: subscriptions)
                }
                .alert(isPresented: hasFailure, error: failure.map(ImportError.init)) {}
        } header: {
            Text("Dati")
        } footer: {
            Text("Esporta crea un file con tutti gli abbonamenti: lo salvi dove vuoi tu. Importa legge un file della versione precedente, di questa o di un foglio di calcolo, e ti fa scegliere le righe.")
        }
    }

    private var hasFailure: Binding<Bool> {
        Binding { failure != nil } set: { if !$0 { failure = nil } }
    }

    private func read(_ result: Result<URL, any Error>) {
        guard let url = try? result.get() else { return }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url) else {
            failure = .empty
            return
        }
        let text = String(decoding: data, as: UTF8.self)
        do {
            file = try CSVImport(text: text, mainCurrency: currency.mainCurrency, today: .now, locale: .current, calendar: .current)
        } catch {
            failure = error
        }
    }
}

/// Why a file couldn't be imported, in words.
struct ImportError: LocalizedError {
    let failure: CSVImport.Failure

    init(_ failure: CSVImport.Failure) {
        self.failure = failure
    }

    var errorDescription: String? {
        switch failure {
        case .empty: String(localized: "Il file è vuoto o non si legge.")
        case .unknownColumns: String(localized: "Nel file non trovo le colonne del nome e del prezzo.")
        }
    }
}
