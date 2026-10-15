import Foundation

/// How the figure reads an angle: degrees, slope in percent, rise on 12 for roofs, or 1V:H.
nonisolated enum AngleUnit: String, CaseIterable, Codable, Identifiable, Sendable {
    /// Degrees to the tenth: the default.
    case degrees
    /// Whole degrees.
    case wholeDegrees
    /// Slope as a percentage: rise over run, times 100.
    case percent
    /// Rise on a run of 12, as roofers read a pitch.
    case pitch
    /// Run for a rise of 1, as engineers write an embankment: 1V:H.
    case ratio

    /// Shown and saved when nothing was chosen.
    static let standard = AngleUnit.degrees

    /// The angle in degrees, to a tenth, from which a slope is too steep to read: tan(90°) has no value.
    static let steepestSlope = 89.95
    /// The angle in degrees, to a tenth, under which a ratio has no run to read: 1/tan(0°) has no value.
    static let flattestRatio = 0.05

    var id: Self { self }

    /// Name in the settings picker.
    var name: LocalizedStringResource {
        switch self {
        case .degrees: "Gradi al decimo"
        case .wholeDegrees: "Gradi interi"
        case .percent: "Pendenza in %"
        case .pitch: "Alzata su 12 (x:12)"
        case .ratio: "Rapporto 1V:H"
        }
    }

    /// Symbol after the figure, `nil` when the figure carries its own (1:H).
    var symbol: String? {
        switch self {
        case .degrees, .wholeDegrees: "°"
        case .percent: "%"
        case .pitch: ":12"
        case .ratio: nil
        }
    }

    /// Digits after the decimal separator.
    var fractionLength: Int {
        self == .wholeDegrees ? 0 : 1
    }

    /// The figure for an angle in degrees, rounded half away from zero to `fractionLength` digits,
    /// never -0. `nil` when the unit has no value there: a slope at 90°, a ratio at 0°.
    func value(forDegrees degrees: Double) -> Double? {
        let raw: Double
        switch self {
        case .degrees, .wholeDegrees:
            raw = degrees
        case .percent, .pitch:
            guard abs(degrees) < Self.steepestSlope else { return nil }
            raw = tan(Angles.radians(fromDegrees: degrees)) * (self == .percent ? 100 : 12)
        case .ratio:
            guard abs(degrees) >= Self.flattestRatio else { return nil }
            raw = 1 / tan(Angles.radians(fromDegrees: degrees))
        }
        let scale = pow(10, Double(fractionLength))
        let rounded = (raw * scale).rounded(.toNearestOrAwayFromZero) / scale
        return rounded == 0 ? 0 : rounded
    }
}
