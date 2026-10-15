import SbuKit
import SwiftData
import SwiftUI

/// Every fuel-up and service of the vehicle by month, newest first. Tap one to edit it, swipe to delete.
struct HistoryView: View {
    let vehicle: Vehicle
    let units: UnitSettings

    @Environment(\.modelContext) private var modelContext
    @State private var filter = HistoryFilter.all
    @State private var sheet: HistorySheet?
    @State private var pendingDelete: HistoryEntry?

    var body: some View {
        let consumption = ConsumptionCalculator(vehicle.fillRecords)
        let months = HistoryEntry.months(vehicle, filter: filter, calendar: .current)
        List {
            Section {
                Picker("Mostra", selection: $filter) {
                    ForEach(HistoryFilter.allCases) { filter in
                        Text(filter.name).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("historyFilter")
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            ForEach(months, id: \.month) { month in
                Section {
                    ForEach(month.entries) { entry in
                        HistoryEntryButton(entry: entry, segment: consumption.segment(closedBy: entry.id),
                                           distanceUnit: vehicle.odometerUnit, units: units, open: open, delete: askDelete)
                    }
                } header: {
                    Text(month.month.formatted(.dateTime.month(.wide).year()))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle("Storico")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if months.isEmpty {
                ContentUnavailableView {
                    Label(filter == .services ? "Nessun intervento" : "Nessun rifornimento", systemImage: "list.bullet.rectangle")
                } description: {
                    Text("Quello che registri compare qui, dal più recente. Puoi aggiungere anche voci passate: i consumi si ricalcolano.")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Aggiungi", systemImage: "plus") {
                    Button("Aggiungi rifornimento", systemImage: "fuelpump") { sheet = .newFuelUp }
                    Button("Registra intervento", systemImage: "wrench.and.screwdriver") { sheet = .newService }
                }
                .accessibilityIdentifier("historyAdd")
            }
        }
        .sheet(item: $sheet) { sheet in
            HistorySheetContent(sheet: sheet, vehicle: vehicle, units: units)
        }
        .confirmationDialog("Eliminare questa voce?", isPresented: isConfirmingDelete, titleVisibility: .visible, presenting: pendingDelete) { entry in
            Button("Elimina", role: .destructive) { delete(entry) }
        } message: { _ in
            Text("I consumi si ricalcolano senza.")
        }
    }

    private var isConfirmingDelete: Binding<Bool> {
        Binding { pendingDelete != nil } set: { if !$0 { pendingDelete = nil } }
    }

    private func open(_ entry: HistoryEntry) {
        switch entry {
        case let .fuel(fuelUp): sheet = .fuelUp(fuelUp)
        case let .service(service): sheet = .service(service)
        }
    }

    private func askDelete(_ entry: HistoryEntry) {
        pendingDelete = entry
    }

    private func delete(_ entry: HistoryEntry) {
        switch entry {
        case let .fuel(fuelUp): modelContext.delete(fuelUp)
        case let .service(service): modelContext.delete(service)
        }
        try? modelContext.save()
        pendingDelete = nil
    }
}

#Preview("Light") {
    HistoryPreview()
        .modelContainer(.preview)
}

#Preview("Dark") {
    HistoryPreview()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}

private struct HistoryPreview: View {
    @Query private var vehicles: [Vehicle]

    var body: some View {
        NavigationStack {
            if let vehicle = vehicles.first {
                HistoryView(vehicle: vehicle, units: UnitSettings())
            }
        }
    }
}
