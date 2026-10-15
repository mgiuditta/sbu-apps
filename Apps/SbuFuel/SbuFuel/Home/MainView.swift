import SbuKit
import SwiftData
import SwiftUI

/// The tool screen: the average consumption of the selected vehicle, closed by the full stop,
/// then the secondary figures, the next service, and the way to the log.
struct MainView: View {
    static let selectionKey = "vehicle.selected"

    let units: UnitSettings
    let notifications: ReminderNotifications

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @AppStorage(Self.selectionKey) private var selectedID = ""
    @State private var sheet: HomeSheet?

    private var vehicle: Vehicle? {
        vehicles.first { $0.id.uuidString == selectedID } ?? vehicles.first
    }

    var body: some View {
        List {
            if let vehicle {
                VehicleOverview(vehicle: vehicle, units: units, notifications: notifications)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .overlay {
            if vehicles.isEmpty {
                FirstVehicleView(addVehicle: addVehicle, addSample: addSample)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if vehicle != nil {
                SbuButton("Aggiungi rifornimento", action: addFuelUp)
                    .accessibilityIdentifier("addFuelUp")
                    .padding(.horizontal, SbuTheme.space4)
                    .padding(.vertical, SbuTheme.space2)
                    .background(SbuTheme.surface)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let vehicle {
                    VehicleMenu(vehicles: vehicles, selected: vehicle, select: select, manage: manageVehicles)
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case let .fuelUp(vehicle): FuelUpForm(vehicle: vehicle, fuelUp: nil, units: units)
            case .newVehicle: NavigationStack { VehicleForm(vehicle: nil, units: units, onSave: select) }
            case .vehicles: VehiclesView(units: units, select: select)
            }
        }
        .onChange(of: vehicles.map(\.id), initial: true) {
            // A deleted vehicle hands the selection to the first one left.
            if let vehicle, vehicle.id.uuidString != selectedID { selectedID = vehicle.id.uuidString }
        }
    }

    private func select(_ vehicle: Vehicle) {
        selectedID = vehicle.id.uuidString
    }

    private func addFuelUp() {
        if let vehicle { sheet = .fuelUp(vehicle) }
    }

    private func addVehicle() {
        sheet = .newVehicle
    }

    private func manageVehicles() {
        sheet = .vehicles
    }

    private func addSample() {
        SampleData.insert(into: modelContext, locale: .current)
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(units: UnitSettings(), notifications: ReminderNotifications(center: SilentReminderCenter()))
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentFuel)
}

#Preview("Dark") {
    NavigationStack {
        MainView(units: UnitSettings(), notifications: ReminderNotifications(center: SilentReminderCenter()))
    }
    .modelContainer(.preview)
    .tint(SbuTheme.accentFuel)
    .preferredColorScheme(.dark)
}
