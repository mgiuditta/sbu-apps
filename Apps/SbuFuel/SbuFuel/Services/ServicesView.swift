import SbuKit
import SwiftData
import SwiftUI

/// The service reminders of the vehicle, most urgent first, and the services done.
struct ServicesView: View {
    let vehicle: Vehicle
    let units: UnitSettings
    let notifications: ReminderNotifications

    @Environment(\.modelContext) private var modelContext
    @State private var sheet: HistorySheet?
    @State private var pendingDelete: ServiceEntry?

    var body: some View {
        let reminders = vehicle.sortedReminders()
        let services = (vehicle.services ?? []).sorted { $0.date > $1.date }
        List {
            if !reminders.isEmpty, notifications.access != .allowed {
                NotificationAccessSection(access: notifications.access, ask: askAccess)
            }
            Section {
                ForEach(reminders, id: \.reminder.id) { item in
                    Button {
                        sheet = .reminder(item.reminder)
                    } label: {
                        ReminderRow(reminder: item.reminder, due: item.due, distanceUnit: vehicle.odometerUnit)
                    }
                    .buttonStyle(.plain)
                }
                Button("Aggiungi promemoria", systemImage: "bell.badge") { sheet = .newReminder }
                    .accessibilityIdentifier("addReminder")
                    .listRowBackground(SbuTheme.surfaceRaised)
            } header: {
                Text("Prossime scadenze")
            } footer: {
                if reminders.isEmpty {
                    Text("Per esempio cambio olio ogni 15.000 km o 12 mesi: ti avvisa il giorno in cui scade.")
                }
            }
            Section {
                ForEach(services) { service in
                    Button {
                        sheet = .service(service)
                    } label: {
                        ServiceRow(service: service, distanceUnit: vehicle.odometerUnit)
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button("Elimina", systemImage: "trash", role: .destructive) { pendingDelete = service }
                    }
                }
                Button("Registra intervento", systemImage: "wrench.and.screwdriver") { sheet = .newService }
                    .accessibilityIdentifier("addService")
                    .listRowBackground(SbuTheme.surfaceRaised)
            } header: {
                Text("Interventi fatti")
            } footer: {
                Text("Quando registri un intervento, il promemoria dello stesso tipo riparte da lì.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Manutenzione")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sheet) { sheet in
            HistorySheetContent(sheet: sheet, vehicle: vehicle, units: units, notifications: notifications)
        }
        .confirmationDialog("Eliminare questo intervento?", isPresented: isConfirmingDelete, titleVisibility: .visible, presenting: pendingDelete) { service in
            Button("Elimina", role: .destructive) { delete(service) }
        }
        .task { await notifications.refreshAccess() }
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding { pendingDelete != nil } set: { if !$0 { pendingDelete = nil } }
    }

    private func askAccess() {
        Task { await notifications.requestAccess() }
    }

    private func delete(_ service: ServiceEntry) {
        modelContext.delete(service)
        try? modelContext.save()
        pendingDelete = nil
    }
}

#Preview("Light") {
    ServicesPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    ServicesPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct ServicesPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        NavigationStack {
            if let vehicle = vehicles.first {
                ServicesView(vehicle: vehicle, units: UnitSettings(), notifications: ReminderNotifications(center: SilentReminderCenter(access: .denied)))
            }
        }
    }
}
