import SbuKit
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Settings → export the selected vehicle's log as CSV, or import a CSV into it after mapping the columns.
struct DataSection: View {
    let units: UnitSettings

    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @AppStorage(MainView.selectionKey) private var selectedID = ""
    @State private var isImporting = false
    @State private var file: ImportFile?
    @State private var failure: ImportFailure?

    private var vehicle: Vehicle? {
        vehicles.first { $0.id.uuidString == selectedID } ?? vehicles.first
    }

    var body: some View {
        Section {
            if let vehicle {
                let export = export(vehicle)
                // Words only: beside a symbol the audit finds the title clipped at larger text (as in Sbu Habits).
                ShareLink(item: export, preview: SharePreview(export.fileName)) {
                    Text("Esporta CSV di \(vehicle.name)")
                }
                .disabled(!vehicle.hasEntries)
                .accessibilityIdentifier("exportCSV")
                Button("Importa CSV in \(vehicle.name)") { isImporting = true }
                    .accessibilityIdentifier("importCSV")
            }
        } header: {
            Text("Dati")
        } footer: {
            Text(vehicle == nil
                 ? "Aggiungi un veicolo per esportare o importare i suoi dati."
                 : "Esporta crea un file con i rifornimenti e gli interventi del veicolo: lo salvi dove vuoi tu. Importa legge un file CSV, anche da altri servizi, e ti fa scegliere le colonne.")
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.commaSeparatedText, .plainText, .text], onCompletion: read)
        .sheet(item: $file) { file in
            if let vehicle {
                CSVImportView(file: file, vehicle: vehicle, units: units)
            }
        }
        .alert(isPresented: hasFailure, error: failure) {}
    }

    private func export(_ vehicle: Vehicle) -> FuelCSVExport {
        FuelCSVExport(
            vehicleName: vehicle.name,
            unit: vehicle.odometerUnit,
            fuel: (vehicle.fuelUps ?? []).map { FuelCSVExport.Fuel(record: $0.record, currencyCode: $0.currencyCode, station: $0.station, note: $0.note) },
            services: (vehicle.services ?? []).map {
                FuelCSVExport.Service(title: $0.title, date: $0.date, odometerKm: $0.odometerKm, cost: $0.cost, currencyCode: $0.currencyCode, note: $0.note)
            }
        )
    }

    private var hasFailure: Binding<Bool> {
        Binding { failure != nil } set: { if !$0 { failure = nil } }
    }

    private func read(_ result: Result<URL, any Error>) {
        guard let url = try? result.get() else { return }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url) else {
            failure = .unreadable
            return
        }
        // Spreadsheets on Windows still save Latin-1: read it rather than turning accents into question marks.
        let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""
        guard let importer = CSVImporter(text: text) else {
            failure = .empty
            return
        }
        file = ImportFile(importer: importer, name: url.lastPathComponent)
    }
}

#Preview("Light") {
    List {
        DataSection(units: UnitSettings())
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    List {
        DataSection(units: UnitSettings())
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
