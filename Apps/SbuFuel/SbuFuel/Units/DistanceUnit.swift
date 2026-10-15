import Foundation

/// The unit of a vehicle's odometer. Stored values are always kilometres.
nonisolated enum DistanceUnit: String, CaseIterable, Identifiable, Sendable {
    case kilometres = "km"
    case miles = "mi"

    var id: Self { self }

    var unit: UnitLength {
        self == .kilometres ? .kilometers : .miles
    }

    var symbol: String { rawValue }

    var name: LocalizedStringResource {
        self == .kilometres ? "Chilometri" : "Miglia"
    }

    func value(fromKm km: Double) -> Double {
        self == .kilometres ? km : Measurement(value: km, unit: UnitLength.kilometers).converted(to: .miles).value
    }

    func km(from value: Double) -> Double {
        self == .kilometres ? value : Measurement(value: value, unit: UnitLength.miles).converted(to: .kilometers).value
    }

    /// An odometer reading or a distance, whole: "45.210 km".
    func formatted(km: Double, locale: Locale = .current) -> String {
        value(fromKm: km).rounded().formatted(.number.precision(.fractionLength(0)).locale(locale)) + "\u{00A0}" + symbol
    }

    /// Miles in the United States and in the United Kingdom, kilometres everywhere else.
    static func preferred(for locale: Locale) -> DistanceUnit {
        locale.measurementSystem == .metric ? .kilometres : .miles
    }
}
