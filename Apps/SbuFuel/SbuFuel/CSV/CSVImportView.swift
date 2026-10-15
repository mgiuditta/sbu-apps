import SbuKit
import SwiftData
import SwiftUI

/// Map the columns of a CSV file, pick its units, look at the first rows, then import into the vehicle.
struct CSVImportView: View {
    let file: ImportFile
    let vehicle: Vehicle
    let units: UnitSettings

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var mapping: [ImportField: Int]
    @State private var options: CSVImporter.Options

    init(file: ImportFile, vehicle: Vehicle, units: UnitSettings) {
        self.file = file
        self.vehicle = vehicle
        self.units = units
        let mapping = ImportField.guess(file.importer.header)
        _mapping = State(initialValue: mapping)
        let dates = file.importer.rows.prefix(50).map { CSVImporter.cell(.date, in: $0, mapping: mapping) }
        let named = ImportField.units(file.importer.header, mapping: mapping)
        _options = State(initialValue: CSVImporter.Options(distanceUnit: named.distance ?? vehicle.odometerUnit, volumeUnit: named.volume ?? units.volume,
                                                           dateOrder: DateOrder.detect(dates, locale: .current)))
    }

    var body: some View {
        let result = file.importer.entries(mapping: mapping, options: options, existing: existing, calendar: .current)
        NavigationStack {
            Form {
                // What will be imported first, then what to change if it reads wrong.
                Section {
                    ForEach(Array(result.entries.prefix(5).enumerated()), id: \.offset) { _, entry in
                        ImportPreviewRow(entry: entry, distanceUnit: vehicle.odometerUnit, volumeUnit: units.volume)
                    }
                    if result.entries.isEmpty {
                        Text("Con queste colonne non si legge nessuna riga.")
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                } header: {
                    Text("Anteprima di \(file.name)")
                } footer: {
                    Text(summary(result))
                        .accessibilityIdentifier("importSummary")
                }
                Section("Unità del file") {
                    Picker("Contachilometri", selection: $options.distanceUnit) {
                        ForEach(DistanceUnit.allCases) { unit in
                            Text(unit.name).tag(unit)
                        }
                    }
                    Picker("Quantità", selection: $options.volumeUnit) {
                        ForEach(VolumeUnit.allCases) { unit in
                            Text(unit.name).tag(unit)
                        }
                    }
                    Picker("Date", selection: $options.dateOrder) {
                        ForEach(DateOrder.allCases) { order in
                            Text(order.name).tag(order)
                        }
                    }
                }
                Section {
                    ForEach(ImportField.allCases) { field in
                        Picker(selection: column(field)) {
                            Text("Nessuna").tag(-1)
                            ForEach(file.importer.header.indices, id: \.self) { index in
                                Text(verbatim: header(index)).tag(index)
                            }
                        } label: {
                            Text(field.name)
                        }
                    }
                } header: {
                    Text("Colonne")
                } footer: {
                    Text("Le righe con tipo “intervento” diventano interventi, le altre rifornimenti. Senza la colonna Pieno, ogni rifornimento conta come pieno.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle("Importa CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Importa") { save(result.entries) }
                        .disabled(result.entries.isEmpty)
                        .accessibilityIdentifier("confirmImport")
                }
            }
        }
    }

    /// The entries already in the vehicle, so the same file imported twice adds nothing.
    private var existing: [ImportedEntry] {
        (vehicle.fuelUps ?? []).map { .fuel($0.record, station: $0.station, note: $0.note) }
            + (vehicle.services ?? []).map { .service(title: $0.title, date: $0.date, odometerKm: $0.odometerKm, cost: $0.cost, note: $0.note) }
    }

    private func header(_ index: Int) -> String {
        let name = file.importer.header[index]
        return name.isEmpty ? String(localized: "Colonna \(index + 1)") : name
    }

    private func column(_ field: ImportField) -> Binding<Int> {
        Binding {
            mapping[field] ?? -1
        } set: { index in
            mapping[field] = index < 0 ? nil : index
        }
    }

    private func summary(_ result: CSVImporter.Result) -> LocalizedStringKey {
        var text: LocalizedStringKey = "Da importare: \(result.entries.count)."
        if result.duplicates > 0 { text = "Da importare: \(result.entries.count). Già presenti o ripetute: \(result.duplicates)." }
        if result.unreadable > 0 {
            text = "Da importare: \(result.entries.count). Già presenti o ripetute: \(result.duplicates). Senza data, contachilometri o quantità: \(result.unreadable)."
        }
        return text
    }

    private func close() {
        dismiss()
    }

    private func save(_ entries: [ImportedEntry]) {
        let currency = Money.currencyCode(for: .current)
        for entry in entries {
            switch entry {
            case let .fuel(record, station, note):
                modelContext.insert(FuelUp(vehicle: vehicle, date: record.date, odometerKm: record.odometerKm, litres: record.litres,
                                           totalPrice: record.totalPrice, currencyCode: currency, isFull: record.isFull,
                                           missedPrevious: record.missedPrevious, station: station, note: note))
            case let .service(title, date, odometerKm, cost, note):
                modelContext.insert(ServiceEntry(vehicle: vehicle, kind: .custom, title: title, date: date, odometerKm: odometerKm,
                                                 cost: cost, currencyCode: currency, note: note))
            }
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    CSVImportPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    CSVImportPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct CSVImportPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        if let vehicle = vehicles.first, let importer = CSVImporter(text: "date,odometer,gallons,price\n2026-03-01,1200,10,3.5\n2026-03-15,1500,11,3.6\n") {
            CSVImportView(file: ImportFile(importer: importer, name: "fuelups.csv"), vehicle: vehicle, units: UnitSettings())
        }
    }
}
