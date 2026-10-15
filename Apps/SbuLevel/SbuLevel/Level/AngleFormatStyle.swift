import Foundation

/// Formats an angle in degrees as the figure of an `AngleUnit`, without its symbol: "32,4", "1:1,6",
/// or a dash where the unit has no value.
nonisolated struct AngleFormatStyle: FormatStyle {
    /// Shown where the unit has no value, such as a slope at 90°.
    static let noValue = "—"

    var unit: AngleUnit
    var locale: Locale = .autoupdatingCurrent

    private var numberStyle: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(unit.fractionLength)).locale(locale)
    }

    func format(_ degrees: Double) -> String {
        guard let value = unit.value(forDegrees: degrees) else { return Self.noValue }
        let number = value.formatted(numberStyle)
        return unit == .ratio ? "1:" + number : number
    }

    /// The figure and its unit in words, for VoiceOver and the spoken reading: "32,4 gradi",
    /// "6,0 su 12".
    func spokenText(_ degrees: Double) -> String {
        guard let value = unit.value(forDegrees: degrees) else {
            return String(localized: "Fuori scala", locale: locale)
        }
        let number = value.formatted(numberStyle)
        switch unit {
        case .degrees, .wholeDegrees:
            return Measurement(value: value, unit: UnitAngle.degrees)
                .formatted(.measurement(width: .wide, usage: .asProvided, numberFormatStyle: numberStyle).locale(locale))
        case .percent:
            return String(localized: "\(number) per cento", locale: locale)
        case .pitch:
            return String(localized: "\(number) su 12", locale: locale)
        case .ratio:
            return String(localized: "1 a \(number)", locale: locale)
        }
    }
}
