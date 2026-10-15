import Foundation

/// The one sheet the tool screen can show at a time.
enum HomeSheet: Identifiable {
    case fuelUp(Vehicle)
    case newVehicle
    case vehicles

    var id: String {
        switch self {
        case let .fuelUp(vehicle): "fuelUp-\(vehicle.id)"
        case .newVehicle: "newVehicle"
        case .vehicles: "vehicles"
        }
    }
}
