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
            // Icon and name, not a Label: in the bar a Label shows its icon only, and the name says which vehicle you are on.
            HStack(spacing: SbuTheme.space1) {
                Image(systemName: selected.kind.systemImage)
                    .fontWeight(.medium)
                // A long name stops short of the app's title.
                Text(shortName)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .imageScale(.small)
                    .fontWeight(.medium)
            }
            .foregroundStyle(SbuTheme.ink)
        }
        // In ink, like the gear: on this screen the accent belongs to the figure's full stop.
        .tint(SbuTheme.ink)
        .accessibilityLabel(Text("Veicolo: \(selected.name)"))
        .accessibilityIdentifier("vehicleMenu")
    }

    /// At most 12 characters: the bar also holds the app's title and the gear.
    private var shortName: String {
        selected.name.count > 12 ? String(selected.name.prefix(11)).trimmingCharacters(in: .whitespaces) + "…" : selected.name
    }

    private var selection: Binding<UUID> {
        Binding {
            selected.id
        } set: { id in
            if let vehicle = vehicles.first(where: { $0.id == id }) { select(vehicle) }
        }
    }
}

#Preview("Light") {
    VehicleMenuPreview()
}

#Preview("Dark") {
    VehicleMenuPreview()
        .preferredColorScheme(.dark)
}

private struct VehicleMenuPreview: View {
    private let vehicles = [Vehicle(name: "Panda"), Vehicle(name: "Vespa", kind: .motorcycle)]

    var body: some View {
        NavigationStack {
            Color.clear
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        VehicleMenu(vehicles: vehicles, selected: vehicles[0], select: { _ in }, manage: {})
                    }
                }
        }
    }
}
