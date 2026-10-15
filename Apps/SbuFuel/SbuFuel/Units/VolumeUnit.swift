import Foundation

/// How fuel quantities are typed and shown. Stored values are always litres.
nonisolated enum VolumeUnit: String, CaseIterable, Identifiable, Sendable {
    case litres
    case usGallons
    case imperialGallons

    var id: Self { self }

    var unit: UnitVolume {
        switch self {
        case .litres: .liters
        case .usGallons: .gallons
        case .imperialGallons: .imperialGallons
        }
    }

    /// The short symbol after a price per unit: "€/L".
    var symbol: String {
        switch self {
        case .litres: "L"
        case .usGallons, .imperialGallons: "gal"
        }
    }

    /// The name in the units picker and above the quantity field.
    var name: LocalizedStringResource {
        switch self {
        case .litres: "Litri"
        case .usGallons: "Galloni USA"
        case .imperialGallons: "Galloni UK"
        }
    }

    func value(fromLitres litres: Double) -> Double {
        Measurement(value: litres, unit: UnitVolume.liters).converted(to: unit).value
    }

    func litres(from value: Double) -> Double {
        Measurement(value: value, unit: unit).converted(to: .liters).value
    }

    /// A quantity such as "42,50 L", two decimals as on a pump receipt.
    func formatted(litres: Double, locale: Locale = .current) -> String {
        value(fromLitres: litres).formatted(.number.precision(.fractionLength(2)).locale(locale)) + "\u{00A0}" + symbol
    }

    /// Gallons in the United States, litres everywhere else: British pumps sell litres too.
    static func preferred(for locale: Locale) -> VolumeUnit {
        locale.measurementSystem == .us ? .usGallons : .litres
    }
}
