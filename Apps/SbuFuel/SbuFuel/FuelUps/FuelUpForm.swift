import SbuKit
import SwiftData
import SwiftUI

/// Add or edit a fuel-up: the odometer first, then quantity and price, full tank or partial.
struct FuelUpForm: View {
    private enum Field: Hashable {
        case odometer
    }

    let vehicle: Vehicle
    let fuelUp: FuelUp?
    let units: UnitSettings
    /// Runs after the fill-up is saved, before the sheet goes: the tool screen closes it with "Registrato".
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var draft: FuelUpDraft
    @FocusState private var focused: Field?

    private var problem: FuelUpDraft.Problem? {
        draft.problem(id: fuelUp?.id, among: vehicle.odometerReadings, calendar: .current)
    }

    init(vehicle: Vehicle, fuelUp: FuelUp?, units: UnitSettings, onSave: @escaping () -> Void = {}) {
        self.vehicle = vehicle
        self.fuelUp = fuelUp
        self.units = units
        self.onSave = onSave
        if let fuelUp {
            _draft = State(initialValue: FuelUpDraft(fuelUp.record, station: fuelUp.station, note: fuelUp.note,
                                                     distanceUnit: vehicle.odometerUnit, volumeUnit: units.volume))
        } else {
            _draft = State(initialValue: FuelUpDraft(distanceUnit: vehicle.odometerUnit, volumeUnit: units.volume))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Data", selection: $draft.date, in: ...Date.now, displayedComponents: .date)
                    NumberField(title: "Contachilometri", text: $draft.odometerText, unit: vehicle.odometerUnit.symbol, identifier: "odometer")
                        .focused($focused, equals: .odometer)
                } footer: {
                    OdometerFooter(problem: problem, lastKm: fuelUp == nil ? vehicle.lastOdometerKm : nil, unit: vehicle.odometerUnit)
                }
                PriceSection(draft: $draft, tankLitres: vehicle.tankLitres)
                Section {
                    Toggle("Pieno", isOn: $draft.isFull)
                        .accessibilityIdentifier("isFull")
                    Toggle("Rifornimento saltato", isOn: $draft.missedPrevious)
                        .accessibilityIdentifier("missedPrevious")
                } footer: {
                    Text("Pieno: hai riempito il serbatoio. Rifornimento saltato: prima di questo ne hai fatto uno senza registrarlo; il consumo riparte da qui.")
                }
                Section {
                    TextRow(title: "Distributore", text: $draft.station, prompt: "Facoltativo")
                    TextField("Note", text: $draft.note, axis: .vertical)
                }
                if fuelUp != nil {
                    Section {
                        SbuButton("Elimina rifornimento", kind: .destructive, confirmationTitle: "Eliminare questo rifornimento?", action: delete)
                            .accessibilityIdentifier("delete")
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            // One word: between Annulla and Salva a longer title has no room at larger text.
            .navigationTitle("Rifornimento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                        .disabled(problem != nil)
                        .accessibilityIdentifier("save")
                }
            }
            .onAppear(perform: focusOdometer)
        }
    }

    private func focusOdometer() {
        if fuelUp == nil { focused = .odometer }
    }

    private func close() {
        dismiss()
    }

    private func save() {
        guard problem == nil, let record = draft.record() else { return }
        if let fuelUp {
            fuelUp.date = record.date
            fuelUp.odometerKm = record.odometerKm
            fuelUp.litres = record.litres
            fuelUp.totalPrice = record.totalPrice
            fuelUp.isFull = record.isFull
            fuelUp.missedPrevious = record.missedPrevious
            fuelUp.station = draft.station.trimmingCharacters(in: .whitespacesAndNewlines)
            fuelUp.note = draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            modelContext.insert(FuelUp(vehicle: vehicle, date: record.date, odometerKm: record.odometerKm, litres: record.litres,
                                       totalPrice: record.totalPrice, currencyCode: Money.currencyCode(for: .current),
                                       isFull: record.isFull, missedPrevious: record.missedPrevious,
                                       station: draft.station.trimmingCharacters(in: .whitespacesAndNewlines),
                                       note: draft.note.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        try? modelContext.save()
        onSave()
        dismiss()
    }

    private func delete() {
        guard let fuelUp else { return }
        modelContext.delete(fuelUp)
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    FuelUpFormPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    FuelUpFormPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct FuelUpFormPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        if let vehicle = vehicles.first {
            FuelUpForm(vehicle: vehicle, fuelUp: nil, units: UnitSettings())
        }
    }
}
