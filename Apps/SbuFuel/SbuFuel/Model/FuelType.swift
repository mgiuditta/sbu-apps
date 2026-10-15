import Foundation

/// The fuel a vehicle takes.
nonisolated enum FuelType: String, CaseIterable, Identifiable, Sendable {
    case petrol
    case diesel
    case lpg
    case cng
    case other

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .petrol: "Benzina"
        case .diesel: "Gasolio"
        case .lpg: "GPL"
        case .cng: "Metano"
        case .other: "Altro"
        }
    }
}
