import SbuKit
import SwiftData
import SwiftUI

/// Add or edit a vehicle. Its odometer unit is fixed once it has entries; deleting it removes them too.
struct VehicleForm: View {
    let vehicle: Vehicle?
    let units: UnitSettings
    var onSave: (Vehicle) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var draft: VehicleDraft

    init(vehicle: Vehicle?, units: UnitSettings, onSave: @escaping (Vehicle) -> Void = { _ in }) {
        self.vehicle = vehicle
        self.units = units
        self.onSave = onSave
        var draft = VehicleDraft(odometerUnit: vehicle?.odometerUnit ?? .preferred(for: .current), volumeUnit: units.volume)
        if let vehicle {
            draft.name = vehicle.name
            draft.kind = vehicle.kind
            draft.fuelType = vehicle.fuelType
            draft.tankText = vehicle.tankLitres.map { NumberText.text(units.volume.value(fromLitres: $0), fractionDigits: 0...1, locale: .current) } ?? ""
            draft.plate = vehicle.plate
            draft.vin = vehicle.vin
        }
        _draft = State(initialValue: draft)
    }

    var body: some View {
        Form {
            Section {
                TextRow(title: "Nome", text: $draft.name, prompt: "Per esempio Panda", identifier: "vehicleName")
                Picker("Tipo", selection: $draft.kind) {
                    ForEach(VehicleKind.allCases) { kind in
                        Text(kind.name).tag(kind)
                    }
                }
                Picker("Carburante", selection: $draft.fuelType) {
                    ForEach(FuelType.allCases) { fuel in
                        Text(fuel.name).tag(fuel)
                    }
                }
            }
            Section {
                Picker("Contachilometri in", selection: $draft.odometerUnit) {
                    ForEach(DistanceUnit.allCases) { unit in
                        Text(unit.name).tag(unit)
                    }
                }
                .disabled(vehicle?.hasEntries == true)
                NumberField(title: "Serbatoio", text: $draft.tankText, unit: units.volume.symbol, identifier: "tank")
            } footer: {
                Text(vehicle?.hasEntries == true
                     ? "L'unità resta questa: il veicolo ha già delle voci. Il serbatoio è facoltativo: serve a segnalarti una quantità che non ci sta."
                     : "Il serbatoio è facoltativo: serve a segnalarti una quantità che non ci sta.")
            }
            Section {
                TextRow(title: "Targa", text: $draft.plate, prompt: "Facoltativa")
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                TextRow(title: "Telaio", text: $draft.vin, prompt: "Facoltativo")
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            } footer: {
                Text("Facoltativi. Restano solo su questo iPhone.")
            }
            if let vehicle {
                Section {
                    SbuButton("Elimina veicolo", kind: .destructive, confirmationTitle: "Eliminare “\(vehicle.name)” con tutti i suoi rifornimenti e interventi?", action: delete)
                        .accessibilityIdentifier("deleteVehicle")
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle("Veicolo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if vehicle == nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva", action: save)
                    .disabled(!draft.canSave)
                    .accessibilityIdentifier("saveVehicle")
            }
        }
    }

    private func close() {
        dismiss()
    }

    private func save() {
        guard draft.canSave else { return }
        let target = vehicle ?? Vehicle(name: draft.trimmedName)
        target.name = draft.trimmedName
        target.kind = draft.kind
        target.fuelType = draft.fuelType
        if !target.hasEntries { target.odometerUnit = draft.odometerUnit }
        target.tankLitres = draft.tankLitres
        target.plate = draft.plate.trimmingCharacters(in: .whitespacesAndNewlines)
        target.vin = draft.vin.trimmingCharacters(in: .whitespacesAndNewlines)
        if vehicle == nil { modelContext.insert(target) }
        try? modelContext.save()
        onSave(target)
        dismiss()
    }

    private func delete() {
        guard let vehicle else { return }
        modelContext.delete(vehicle)
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    NavigationStack {
        VehicleForm(vehicle: nil, units: UnitSettings())
    }
    .modelContainer(.preview)
}

#Preview("Dark") {
    NavigationStack {
        VehicleForm(vehicle: nil, units: UnitSettings())
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}
