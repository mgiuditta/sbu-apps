import SbuKit
import SwiftData
import SwiftUI

/// Add or edit a service reminder. Saving the first one asks for notifications.
struct ReminderForm: View {
    let vehicle: Vehicle
    let reminder: ServiceReminder?
    var notifications: ReminderNotifications?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var draft: ReminderDraft

    init(vehicle: Vehicle, reminder: ServiceReminder?, notifications: ReminderNotifications?) {
        self.vehicle = vehicle
        self.reminder = reminder
        self.notifications = notifications
        let unit = vehicle.odometerUnit
        var draft = ReminderDraft(distanceUnit: unit)
        if let reminder {
            draft.kind = reminder.kind
            draft.title = reminder.title
            draft.everyKmText = reminder.everyKm.map { NumberText.text(unit.value(fromKm: $0), fractionDigits: 0...0, locale: .current) } ?? ""
            draft.everyMonths = reminder.everyMonths ?? 0
            draft.lastDoneDate = reminder.lastDoneDate
            draft.lastOdometerText = reminder.lastDoneOdometerKm.map { NumberText.text(unit.value(fromKm: $0), fractionDigits: 0...0, locale: .current) } ?? ""
        } else {
            draft.apply(.oilChange)
            draft.lastOdometerText = vehicle.lastOdometerKm.map { NumberText.text(unit.value(fromKm: $0), fractionDigits: 0...0, locale: .current) } ?? ""
        }
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Intervento", selection: kind) {
                        ForEach(ServiceKind.allCases) { kind in
                            Text(kind.name)
                                .tag(kind)
                        }
                    }
                    TextRow(title: "Nome", text: $draft.title, identifier: "reminderTitle")
                }
                Section {
                    NumberField(title: "Ogni", text: $draft.everyKmText, unit: vehicle.odometerUnit.symbol, identifier: "everyKm")
                    Picker("Oppure ogni", selection: $draft.everyMonths) {
                        Text("Mai").tag(0)
                        ForEach([1, 3, 6, 12, 24, 36, 48], id: \.self) { months in
                            Text("^[\(months) mese](inflect: true)").tag(months)
                        }
                    }
                    .accessibilityIdentifier("everyMonths")
                } header: {
                    Text("Quando")
                } footer: {
                    if draft.problem == .noInterval {
                        ProblemLabel(text: Text("Scegli i chilometri, i mesi o entrambi."), tone: .warning)
                    } else {
                        Text("Vale quello che arriva prima.")
                    }
                }
                Section {
                    DatePicker("Data", selection: $draft.lastDoneDate, in: ...Date.now, displayedComponents: .date)
                    NumberField(title: "Contachilometri", text: $draft.lastOdometerText, unit: vehicle.odometerUnit.symbol, identifier: "lastOdometer")
                } header: {
                    Text("L'ultima volta")
                } footer: {
                    if draft.problem == .missingLastReading {
                        ProblemLabel(text: Text("Scrivi il contachilometri dell'ultima volta: da lì contano i chilometri."), tone: .warning)
                    } else {
                        Text("La notifica arriva alle 9:00 del giorno in cui scade. Per i chilometri, il giorno lo stima dai tuoi rifornimenti.")
                    }
                }
                if reminder != nil {
                    Section {
                        SbuButton("Elimina promemoria", kind: .destructive, confirmationTitle: "Eliminare questo promemoria?", action: delete)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.paper)
            .navigationTitle("Promemoria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: close)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva", action: save)
                        .disabled(!draft.canSave)
                        .accessibilityIdentifier("saveReminder")
                }
            }
        }
    }

    /// A new kind brings its preset name and intervals on a new reminder; on a saved one only the kind changes.
    private var kind: Binding<ServiceKind> {
        Binding {
            draft.kind
        } set: { kind in
            if reminder == nil { draft.apply(kind) } else { draft.kind = kind }
        }
    }

    private func close() {
        dismiss()
    }

    private func save() {
        guard draft.canSave else { return }
        let months = draft.everyMonths > 0 ? draft.everyMonths : nil
        let lastKm = draft.lastOdometerKm
        if let reminder {
            reminder.kind = draft.kind
            reminder.title = draft.trimmedTitle
            reminder.everyKm = draft.everyKm
            reminder.everyMonths = months
            reminder.lastDoneDate = draft.lastDoneDate
            reminder.lastDoneOdometerKm = lastKm
        } else {
            modelContext.insert(ServiceReminder(vehicle: vehicle, kind: draft.kind, title: draft.trimmedTitle, everyKm: draft.everyKm,
                                                everyMonths: months, lastDoneDate: draft.lastDoneDate, lastDoneOdometerKm: lastKm))
        }
        try? modelContext.save()
        if let notifications {
            Task { await notifications.requestAccess() }
        }
        dismiss()
    }

    private func delete() {
        guard let reminder else { return }
        modelContext.delete(reminder)
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Light") {
    ReminderFormPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    ReminderFormPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct ReminderFormPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        if let vehicle = vehicles.first {
            ReminderForm(vehicle: vehicle, reminder: nil, notifications: nil)
        }
    }
}
