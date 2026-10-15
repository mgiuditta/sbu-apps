import SbuKit
import SwiftData
import SwiftUI

/// The list of your vehicles: open one to edit or delete it, or add another.
struct VehiclesView: View {
    let units: UnitSettings
    let select: (Vehicle) -> Void

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @State private var isAdding = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(vehicles) { vehicle in
                        NavigationLink {
                            VehicleForm(vehicle: vehicle, units: units)
                        } label: {
                            SbuListRow(
                                "\(vehicle.name)",
                                subtitle: subtitle(vehicle),
                                systemImage: vehicle.kind.systemImage,
                                iconBackground: SbuTheme.surfaceSunken,
                                iconForeground: SbuTheme.ink
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle("Veicoli")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Aggiungi veicolo", systemImage: "plus", action: add)
                        .accessibilityIdentifier("addVehicle")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
            .navigationDestination(isPresented: $isAdding) {
                VehicleForm(vehicle: nil, units: units, onSave: select)
            }
            .overlay {
                if vehicles.isEmpty {
                    ContentUnavailableView("Nessun veicolo", systemImage: "car", description: Text("Aggiungine uno con +."))
                }
            }
        }
    }

    private func subtitle(_ vehicle: Vehicle) -> LocalizedStringKey {
        let kind = String(localized: vehicle.kind.name)
        let fuel = String(localized: vehicle.fuelType.name)
        return vehicle.plate.isEmpty ? "\(kind) · \(fuel)" : "\(kind) · \(fuel) · \(vehicle.plate)"
    }

    private func add() {
        isAdding = true
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    VehiclesView(units: UnitSettings(), select: { _ in })
        .modelContainer(.preview)
}

#Preview("Dark") {
    VehiclesView(units: UnitSettings(), select: { _ in })
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
