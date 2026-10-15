import SbuKit
import SwiftUI

/// The vehicle picker in the toolbar: switch vehicle, or open the list to add and edit them.
struct VehicleMenu: View {
    let vehicles: [Vehicle]
    let selected: Vehicle
    let select: (Vehicle) -> Void
    let manage: () -> Void

    var body: some View {
        Menu {
            Picker("Veicolo", selection: selection) {
                ForEach(vehicles) { vehicle in
                    Label(vehicle.name, systemImage: vehicle.kind.systemImage)
                        .tag(vehicle.id)
                }
            }
            Divider()
            Button("Gestisci veicoli", systemImage: "list.bullet", action: manage)
                .accessibilityIdentifier("manageVehicles")
        } label: {
            Label(selected.name, systemImage: selected.kind.systemImage)
                .labelStyle(.titleAndIcon)
        }
        // In ink, like the gear: on this screen the accent belongs to the figure's full stop.
        .tint(SbuTheme.ink)
        .accessibilityLabel(Text("Veicolo: \(selected.name)"))
        .accessibilityIdentifier("vehicleMenu")
    }

    private var selection: Binding<UUID> {
        Binding {
            selected.id
        } set: { id in
            if let vehicle = vehicles.first(where: { $0.id == id }) { select(vehicle) }
        }
    }
}
