import Foundation

/// The services the app knows, each with the interval a reminder starts from.
nonisolated enum ServiceKind: String, CaseIterable, Identifiable, Sendable {
    case oilChange
    case tyres
    case brakes
    case inspection
    case insurance
    case tax
    case custom

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .oilChange: "Cambio olio"
        case .tyres: "Pneumatici"
        case .brakes: "Freni"
        case .inspection: "Revisione"
        case .insurance: "Assicurazione"
        case .tax: "Bollo"
        case .custom: "Altro"
        }
    }

    var systemImage: String {
        switch self {
        case .oilChange: "drop"
        case .tyres: "circle.circle"
        case .brakes: "exclamationmark.brakesignal"
        case .inspection: "checkmark.seal"
        case .insurance: "doc.text"
        case .tax: "building.columns"
        case .custom: "wrench.and.screwdriver"
        }
    }

    /// The preset interval in kilometres, when the service goes by distance.
    var presetEveryKm: Double? {
        switch self {
        case .oilChange: 15_000
        case .tyres: 10_000
        case .brakes: 30_000
        default: nil
        }
    }

    /// The preset interval in months, when the service goes by time.
    var presetEveryMonths: Int? {
        switch self {
        case .oilChange, .insurance, .tax: 12
        case .inspection: 24
        default: nil
        }
    }
}
