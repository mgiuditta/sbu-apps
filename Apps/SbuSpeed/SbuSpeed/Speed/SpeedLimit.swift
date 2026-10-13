import Foundation

/// A speed the person does not want to go over, in the unit shown when it was chosen.
nonisolated struct SpeedLimit: Codable, Hashable, Sendable {
    /// Whole units, such as 50 for 50 km/h.
    var value: Int
    var unit: SpeedUnit

    /// The limits offered in settings: the usual road limits in km/h and mph,
    /// the usual limits on the water in knots (harbours, coastal strips).
    static func presets(for unit: SpeedUnit) -> [SpeedLimit] {
        let values = switch unit {
        case .kilometersPerHour: [30, 50, 70, 90, 110, 130]
        case .milesPerHour: [20, 30, 40, 50, 60, 70, 80]
        // From 5 up: the alarm re-arms 3 units below the limit, which a 3 kn limit could never reach.
        case .knots: [5, 10, 15, 20, 25, 30]
        }
        return values.map { SpeedLimit(value: $0, unit: unit) }
    }

    /// The preset of `unit` closest to this limit: 50 km/h becomes 30 mph.
    func converted(to unit: SpeedUnit) -> SpeedLimit {
        guard unit != self.unit else { return self }
        let target = Measurement(value: Double(value), unit: self.unit.speed).converted(to: unit.speed).value
        let nearest = Self.presets(for: unit).min { abs(Double($0.value) - target) < abs(Double($1.value) - target) }
        return nearest ?? SpeedLimit(value: Int(target.rounded()), unit: unit)
    }

    /// Whether a speed in metres per second reads above the limit: the whole number on screen is higher.
    func isExceeded(byMetersPerSecond speed: Double) -> Bool {
        // The figure rounds half to even, as the number format style does.
        unit.value(ofMetersPerSecond: speed).rounded(.toNearestOrEven) > Double(value)
    }

    /// The limit with its unit: "50 km/h".
    func text(locale: Locale = .autoupdatingCurrent) -> String {
        unit.speedText(value: Double(value), locale: locale)
    }
}
