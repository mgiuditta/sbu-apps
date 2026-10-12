import Foundation

/// The unit the speed is shown in, with the distance unit that goes with it.
nonisolated enum SpeedUnit: String, CaseIterable, Codable, Identifiable, Sendable {
    case kilometersPerHour
    case milesPerHour

    var id: Self { self }

    var speed: UnitSpeed {
        switch self {
        case .kilometersPerHour: .kilometersPerHour
        case .milesPerHour: .milesPerHour
        }
    }

    var length: UnitLength {
        switch self {
        case .kilometersPerHour: .kilometers
        case .milesPerHour: .miles
        }
    }

    /// Short symbol next to the figure: "km/h" or "mph".
    var symbol: String { speed.symbol }

    /// The top of the gauge, in this unit.
    var fullScale: Double {
        switch self {
        case .kilometersPerHour: 200
        case .milesPerHour: 130
        }
    }

    /// km/h where the metric system is used, mph in the US and the UK.
    static func preferred(for locale: Locale) -> SpeedUnit {
        locale.measurementSystem == .metric ? .kilometersPerHour : .milesPerHour
    }

    /// Converts a speed in metres per second to this unit.
    func value(ofMetersPerSecond metersPerSecond: Double) -> Double {
        Measurement(value: metersPerSecond, unit: UnitSpeed.metersPerSecond).converted(to: speed).value
    }

    /// A speed in metres per second, rounded to the unit: "87 km/h".
    func speedText(metersPerSecond: Double, locale: Locale = .autoupdatingCurrent) -> String {
        Measurement(value: metersPerSecond, unit: UnitSpeed.metersPerSecond)
            .converted(to: speed)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0))).locale(locale))
    }

    /// A distance in metres, in km or mi to one decimal: "12,4 km".
    func distanceText(meters: Double, locale: Locale = .autoupdatingCurrent) -> String {
        Measurement(value: meters, unit: UnitLength.meters)
            .converted(to: length)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(1))).locale(locale))
    }
}
