import Foundation

/// The unit the speed is shown in, with the distance unit that goes with it.
nonisolated enum SpeedUnit: String, CaseIterable, Codable, Identifiable, Sendable {
    case kilometersPerHour
    case milesPerHour
    case knots

    var id: Self { self }

    var speed: UnitSpeed {
        switch self {
        case .kilometersPerHour: .kilometersPerHour
        case .milesPerHour: .milesPerHour
        case .knots: .knots
        }
    }

    var length: UnitLength {
        switch self {
        case .kilometersPerHour: .kilometers
        case .milesPerHour: .miles
        case .knots: .nauticalMiles
        }
    }

    /// The unit's name in settings: "Nodi" says more than "kn" to whom has never used it.
    var name: LocalizedStringResource {
        switch self {
        case .kilometersPerHour: "Chilometri orari"
        case .milesPerHour: "Miglia orarie"
        case .knots: "Nodi"
        }
    }

    /// Short symbol next to the figure: "km/h", "mph" or "kn".
    var symbol: String { speed.symbol }

    /// km/h where the metric system is used, mph in the US and the UK. Knots are only a choice: no region drives in them.
    static func preferred(for locale: Locale) -> SpeedUnit {
        locale.measurementSystem == .metric ? .kilometersPerHour : .milesPerHour
    }

    /// Converts a speed in metres per second to this unit.
    func value(ofMetersPerSecond metersPerSecond: Double) -> Double {
        Measurement(value: metersPerSecond, unit: UnitSpeed.metersPerSecond).converted(to: speed).value
    }

    /// A speed in metres per second, rounded to the unit: "87 km/h".
    func speedText(metersPerSecond: Double, locale: Locale = .autoupdatingCurrent) -> String {
        speedText(value: value(ofMetersPerSecond: metersPerSecond), locale: locale)
    }

    /// A speed already in this unit, rounded: "50 km/h".
    func speedText(value: Double, locale: Locale = .autoupdatingCurrent) -> String {
        Measurement(value: value, unit: speed)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0))).locale(locale))
    }

    /// The unit of the altitude: metres with km/h, feet with mph; with knots, what the region uses.
    func altitudeLength(locale: Locale) -> UnitLength {
        switch self {
        case .kilometersPerHour: .meters
        case .milesPerHour: .feet
        case .knots: locale.measurementSystem == .metric ? .meters : .feet
        }
    }

    /// An altitude in metres, whole, in the unit that goes with this speed: "122 m", "400 ft".
    func altitudeText(meters: Double, width: Measurement<UnitLength>.FormatStyle.UnitWidth, locale: Locale = .autoupdatingCurrent) -> String {
        Measurement(value: meters, unit: UnitLength.meters)
            .converted(to: altitudeLength(locale: locale))
            .formatted(.measurement(width: width, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0))).locale(locale))
    }

    /// A distance in metres, in km, mi or nautical miles to one decimal: "12,4 km".
    func distanceText(meters: Double, locale: Locale = .autoupdatingCurrent) -> String {
        Measurement(value: meters, unit: UnitLength.meters)
            .converted(to: length)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(1))).locale(locale))
    }
}
