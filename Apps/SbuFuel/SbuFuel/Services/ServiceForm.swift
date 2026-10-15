import SbuKit
import SwiftData
import SwiftUI

/// Log a service, or edit one. Saving moves forward the reminder of the same service.
struct ServiceForm: View {
    let vehicle: Vehicle
    let service: ServiceEntry?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var draft: ServiceDraft

    private var conflict: OdometerConflict? {
        guard let km = draft.odometerKm else { return nil }
        let fuelUps = vehicle.odometerReadings.filter { $0.source == .fuelUp }
        return OdometerConflict.check(id: service?.id, date: draft.date, km: km, among: fuelUps, calendar: .current)
    }

    init(vehicle: Vehicle, service: ServiceEntry?) {
        self.vehicle = vehicle
        self.service = service
        var draft = ServiceDraft(distanceUnit: vehicle.odometerUnit)
        if let service {
            draft.kind = service.kind
            draft.title = service.title
            draft.date = service.date
            draft.odometerText = service.odometerKm.map { NumberText.text(vehicle.odometerUnit.value(fromKm: $0), fractionDigits: 0...1, locale: .current) } ?? ""
            draft.costText = NumberText.text(service.cost, locale: .current)
            draft.note = service.note
        } else {
            draft.title = String(localized: ServiceKind.oilChange.name)
        }
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Intervento", selection: $draft.kind) {
                        ForEach(ServiceKind.allCases) { kind in
                            Label { Text(kind.name) } icon: { Image(systemName: kind.systemImage) }
                                .tag(kind)
                        }
                    }
                    .onChange(of: draft.kind, renameForKind)
                    TextField("Nome", text: $draft.title)
                        .accessibilityIdentifier("serviceTitle")
                }
                Section {
                    DatePicker("Data", selection: $draft.date, in: ...Date.now, displayedComponents: .date)
                    NumberField(title: "Contachilometri", text: $draft.odometerText, unit: vehicle.odometerUnit.symbol, identifier: "serviceOdometer")
                    NumberField(title: "Costo", text: $draft.costText, unit: Locale.current.currencySymbol ?? "", identifier: "serviceCost")
                } footer: {
                    if let conflict {
                        OdometerFooter(problem: .conflict(conflict), lastKm: nil, unit: vehicle.odometerUnit)
                    } else {
                        Text("Il contachilometri è facoltativo, per esempio per bollo e assicurazione.")
                    }
                }
                Section {
                    TextField("Note", text: $draft.note, axis: .vertical)
                }
                if service != nil {
                    Section {
                        SbuButton("Elimina intervento", kind: .destructive, confirmationTitle: "Eliminare questo intervento?", action: delete)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle(service == nil ? "Nuovo intervento" : "Intervento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                        .disabled(!draft.canSave || conflict != nil)
                        .accessibilityIdentifier("saveService")
                }
            }
        }
    }

    /// The name follows the kind until you type your own.
    private func renameForKind(_ old: ServiceKind, _ new: ServiceKind) {
        if draft.trimmedTitle.isEmpty || draft.trimmedTitle == String(localized: old.name) {
            draft.title = new == .custom ? "" : String(localized: new.name)
        }
    }

    private func close() {
        dismiss()
    }

    private func save() {
        guard draft.canSave, conflict == nil else { return }
        let target = service ?? ServiceEntry(vehicle: vehicle, kind: draft.kind, title: draft.trimmedTitle, date: draft.date,
                                             odometerKm: draft.odometerKm, cost: draft.cost, currencyCode: Money.currencyCode(for: .current))
        target.kind = draft.kind
        target.title = draft.trimmedTitle
        target.date = draft.date
        target.odometerKm = draft.odometerKm
        target.cost = draft.cost
        target.note = draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if service == nil { modelContext.insert(target) }
        vehicle.rollReminders(for: target)
        try? modelContext.save()
        dismiss()
    }

    private func delete() {
        guard let service else { return }
        modelContext.delete(service)
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    ServiceFormPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    ServiceFormPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct ServiceFormPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        if let vehicle = vehicles.first {
            ServiceForm(vehicle: vehicle, service: nil)
        }
    }
}
