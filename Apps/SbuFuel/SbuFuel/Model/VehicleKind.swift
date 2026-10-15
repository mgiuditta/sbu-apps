import Foundation

/// What kind of vehicle it is: only the symbol and the name change.
nonisolated enum VehicleKind: String, CaseIterable, Identifiable, Sendable {
    case car
    case motorcycle
    case van
    case other

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .car: "Auto"
        case .motorcycle: "Moto"
        case .van: "Furgone"
        case .other: "Altro"
        }
    }

    var systemImage: String {
        switch self {
        case .car: "car"
        case .motorcycle: "motorcycle"
        case .van: "box.truck"
        case .other: "fuelpump"
        }
    }
}
