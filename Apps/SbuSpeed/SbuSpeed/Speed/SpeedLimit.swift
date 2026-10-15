import Foundation

/// A speed the person does not want to go over, in the unit shown when it was chosen.
nonisolated struct SpeedLimit: Codable, Hashable, Sendable {
    /// The lowest limit Altro valore accepts.
    static let lowestValue = 1
    /// How far, as a fraction of the target, a preset may be from a converted limit and still replace it.
    static let presetTolerance = 0.1

    /// Whole units, such as 50 for 50 km/h.
    var value: Int
    var unit: SpeedUnit

    /// The limits offered in settings, from the research in `research/apps/speed.md`: Italian road
    /// limits and the bicycle and e-scooter ones in km/h; every five mph, which covers the odd US
    /// limits and the even UK ones; the limits on lakes, harbours and coastal strips in knots.
    static func presets(for unit: SpeedUnit) -> [SpeedLimit] {
        let values = switch unit {
        case .kilometersPerHour: [20, 25, 30, 50, 70, 90, 110, 130]
        case .milesPerHour: Array(stride(from: 15, through: 80, by: 5))
        case .knots: [3, 5, 6, 8, 10, 12, 15, 20]
        }
        return values.map { SpeedLimit(value: $0, unit: unit) }
    }

    /// The four limits one tap away on the tool screen: town, country road, main road and motorway.
    /// In mph the US limits end in 5 (25 in town, 55 to 70 on highways), the UK ones in 0.
    /// - Parameter region: Picks the US or the UK miles; `nil` counts as the UK.
    static func quickPresets(for unit: SpeedUnit, region: Locale.Region?) -> [SpeedLimit] {
        let values = switch unit {
        case .kilometersPerHour: [50, 90, 110, 130]
        case .milesPerHour: region == .unitedStates ? [25, 55, 65, 70] : [20, 30, 60, 70]
        // Coastal strip, harbour, the most common sea ordinance, Lake Garda by day.
        case .knots: [3, 6, 10, 20]
        }
        return values.map { SpeedLimit(value: $0, unit: unit) }
    }

    /// The highest limit Altro valore accepts in `unit`: the top of its largest dial.
    static func highestValue(for unit: SpeedUnit) -> Int {
        Int(unit.dialScales.last ?? 300)
    }

    /// A limit typed in Altro valore: whole units within range, or `nil`.
    static func custom(_ text: String, unit: SpeedUnit) -> SpeedLimit? {
        guard let value = Int(text.trimmingCharacters(in: .whitespaces)),
              (lowestValue...highestValue(for: unit)).contains(value) else { return nil }
        return SpeedLimit(value: value, unit: unit)
    }

    /// This limit in `unit`: the closest preset when one is within `presetTolerance` (50 km/h becomes
    /// 30 mph), otherwise the converted value rounded (50 km/h becomes 27 kn, not 20).
    func converted(to unit: SpeedUnit) -> SpeedLimit {
        guard unit != self.unit else { return self }
        let target = Measurement(value: Double(value), unit: self.unit.speed).converted(to: unit.speed).value
        if let nearest = Self.presets(for: unit).min(by: { abs(Double($0.value) - target) < abs(Double($1.value) - target) }),
           abs(Double(nearest.value) - target) <= target * Self.presetTolerance {
            return nearest
        }
        let value = min(Self.highestValue(for: unit), max(Self.lowestValue, Int(target.rounded())))
        return SpeedLimit(value: value, unit: unit)
    }

    /// How far under the limit, in its unit, the speed must drop before the next crossing alerts:
    /// a tenth of the limit, from 1 to 3 units, so 3 kn re-arms at 2 kn and 130 km/h at 127.
    var rearmMargin: Double {
        min(3, max(1, Double(value) / 10))
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

    /// The limit alone, for a pill under a caption that names the unit: "50".
    func valueText(locale: Locale = .autoupdatingCurrent) -> String {
        value.formatted(.number.locale(locale))
    }
}
