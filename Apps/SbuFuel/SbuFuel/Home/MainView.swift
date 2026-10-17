import SbuKit
import SwiftData
import SwiftUI

/// The tool screen: Consumo medio and its cartiglio, the average consumption of the selected
/// vehicle as the figure on the grid, then the cards on paper: the way into the log, the next
/// service and the secondary figures.
struct MainView: View {
    static let selectionKey = "vehicle.selected"

    let units: UnitSettings
    let notifications: ReminderNotifications

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @AppStorage(Self.selectionKey) private var selectedID = ""
    @State private var sheet: HomeSheet?
    /// A fill-up was saved in the sheet: the Closure waits for the sheet to go, so it is seen.
    @State private var isFuelUpSaved = false
    @State private var isClosing = false
    /// The visible height of the scroll view: on the first run the grid fills it.
    @State private var viewportHeight: CGFloat = 0

    private var vehicle: Vehicle? {
        vehicles.first { $0.id.uuidString == selectedID } ?? vehicles.first
    }

    private var cartiglio: String {
        (["Sbu", String(localized: "Carburante")] + (vehicle.map { [$0.name] } ?? [])).joined(separator: " · ")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                figureZone
                if let vehicle {
                    VehicleOverview(vehicle: vehicle, units: units, notifications: notifications)
                        .padding(.horizontal, SbuTheme.space4)
                        .padding(.bottom, SbuTheme.space6)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            viewportHeight = height
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if vehicle != nil {
                SbuButton("Aggiungi rifornimento", action: addFuelUp)
                    .accessibilityIdentifier("addFuelUp")
                    .padding(.horizontal, SbuTheme.space4)
                    .padding(.vertical, SbuTheme.space2)
                    .background(SbuTheme.paper)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let vehicle {
                    VehicleMenu(vehicles: vehicles, selected: vehicle, select: select, manage: manageVehicles)
                }
            }
        }
        .sheet(item: $sheet, onDismiss: closeFuelUp) { sheet in
            switch sheet {
            case let .fuelUp(vehicle): FuelUpForm(vehicle: vehicle, fuelUp: nil, units: units, onSave: fuelUpSaved)
            case .newVehicle: NavigationStack { VehicleForm(vehicle: nil, units: units, onSave: select) }
            case .vehicles: VehiclesView(units: units, select: select)
            }
        }
        .onChange(of: vehicles.map(\.id), initial: true) {
            // A deleted vehicle hands the selection to the first one left.
            if let vehicle, vehicle.id.uuidString != selectedID { selectedID = vehicle.id.uuidString }
        }
    }

    /// Title, cartiglio and the figure on the grid; on the first run, the grid fills the screen.
    private var figureZone: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuScreenTitle("Consumo medio", cartiglio: cartiglio)
            Group {
                if let vehicle {
                    let records = vehicle.fillRecords
                    ConsumptionFigure(consumption: ConsumptionCalculator(records), hasFuelUps: !records.isEmpty,
                                      unit: units.consumption, distanceUnit: vehicle.odometerUnit)
                } else {
                    FirstVehicleView(addVehicle: addVehicle, addSample: addSample)
                }
            }
            .sbuClosure($isClosing, word: "Registrato")
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.vertical, SbuTheme.space6)
        .frame(maxWidth: .infinity, minHeight: vehicles.isEmpty ? viewportHeight : nil, alignment: .topLeading)
        .sbuPaper(grid: true)
    }

    private func select(_ vehicle: Vehicle) {
        selectedID = vehicle.id.uuidString
    }

    private func addFuelUp() {
        if let vehicle { sheet = .fuelUp(vehicle) }
    }

    private func fuelUpSaved() {
        isFuelUpSaved = true
    }

    /// Once per saved fill-up, when its sheet has gone.
    private func closeFuelUp() {
        guard isFuelUpSaved else { return }
        isFuelUpSaved = false
        isClosing = true
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
    .environment(\.sbuAccent, .fuel)
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        MainView(units: UnitSettings(), notifications: ReminderNotifications(center: SilentReminderCenter()))
    }
    .modelContainer(.preview)
    .environment(\.sbuAccent, .fuel)
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
