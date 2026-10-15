import Foundation

/// How consumption is shown. Stored values are always kilometres per litre.
nonisolated enum ConsumptionUnit: String, CaseIterable, Identifiable, Sendable {
    case litresPer100Km
    case kmPerLitre
    case mpgUS
    case mpgUK

    var id: Self { self }

    /// The unit after the figure. "mpg" for both gallons: the picker says which one.
    var symbol: String {
        switch self {
        case .litresPer100Km: "L/100 km"
        case .kmPerLitre: "km/L"
        case .mpgUS, .mpgUK: "mpg"
        }
    }

    /// The name in the units picker.
    var name: LocalizedStringResource {
        switch self {
        case .litresPer100Km: "L/100 km"
        case .kmPerLitre: "km/L"
        case .mpgUS: "mpg (galloni USA)"
        case .mpgUK: "mpg (galloni UK)"
        }
    }

    /// Whether a smaller number means less fuel burned: true only for L/100 km.
    var lowerIsBetter: Bool { self == .litresPer100Km }

    /// The consumption in this unit, from kilometres per litre.
    func value(fromKmPerLitre kmPerLitre: Double) -> Double {
        guard kmPerLitre > 0 else { return 0 }
        if self == .kmPerLitre { return kmPerLitre }
        let measurement = Measurement(value: 100 / kmPerLitre, unit: UnitFuelEfficiency.litersPer100Kilometers)
        switch self {
        case .mpgUS: return measurement.converted(to: .milesPerGallon).value
        case .mpgUK: return measurement.converted(to: .milesPerImperialGallon).value
        default: return measurement.value
        }
    }

    /// Kilometres per litre, from a consumption in this unit.
    func kmPerLitre(from value: Double) -> Double {
        guard value > 0 else { return 0 }
        let unit: UnitFuelEfficiency
        switch self {
        case .kmPerLitre: return value
        case .litresPer100Km: unit = .litersPer100Kilometers
        case .mpgUS: unit = .milesPerGallon
        case .mpgUK: unit = .milesPerImperialGallon
        }
        return 100 / Measurement(value: value, unit: unit).converted(to: .litersPer100Kilometers).value
    }

    /// One decimal, as on every car's trip computer.
    func formatted(kmPerLitre: Double, locale: Locale = .current) -> String {
        value(fromKmPerLitre: kmPerLitre).formatted(.number.precision(.fractionLength(1)).locale(locale))
    }

    /// The phone's habit: mpg in the United States and in the United Kingdom, L/100 km everywhere else.
    static func preferred(for locale: Locale) -> ConsumptionUnit {
        switch locale.measurementSystem {
        case .us: .mpgUS
        case .uk: .mpgUK
        default: .litresPer100Km
        }
    }
}
