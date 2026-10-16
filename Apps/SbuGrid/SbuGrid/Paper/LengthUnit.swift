import Foundation

/// The unit the sheet and the cells are measured in.
nonisolated enum LengthUnit: String, Codable, CaseIterable, Identifiable, Sendable {
    case centimeters
    case inches

    var id: Self { self }

    /// Centimetres in one unit.
    var centimeters: Double {
        switch self {
        case .centimeters: 1
        case .inches: 2.54
        }
    }

    /// PDF points (1/72 inch) in one unit.
    var points: Double {
        72 * centimeters / 2.54
    }

    /// The smallest change of a cell or a sheet side: half a centimetre, a quarter of an inch.
    var step: Double {
        switch self {
        case .centimeters: 0.5
        case .inches: 0.25
        }
    }

    /// The cell sizes the stepper offers: from 0.5 to 10 cm, from ¼ to 4 inches.
    var cellRange: ClosedRange<Double> {
        switch self {
        case .centimeters: 0.5...10
        case .inches: 0.25...4
        }
    }

    /// The sides a custom sheet can have: from 5 cm to 1.5 m, from 2 to 60 inches.
    var sideRange: ClosedRange<Double> {
        switch self {
        case .centimeters: 5...150
        case .inches: 2...60
        }
    }

    var unitLength: UnitLength {
        switch self {
        case .centimeters: .centimeters
        case .inches: .inches
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .centimeters: "Centimetri"
        case .inches: "Pollici"
        }
    }

    /// Centimetres where the metric system is used, inches in the United States and Liberia.
    static func preferred(for locale: Locale) -> LengthUnit {
        locale.measurementSystem == .us ? .inches : .centimeters
    }

    /// `value` in this unit converted to `other`, on `other`'s step, within `range`.
    func convert(_ value: Double, to other: LengthUnit, within range: ClosedRange<Double>) -> Double {
        let converted = value * centimeters / other.centimeters
        return Self.snap(converted, step: other.step, within: range)
    }

    /// `value` on the nearest multiple of `step`, within `range`; not a number gives the lower bound.
    static func snap(_ value: Double, step: Double, within range: ClosedRange<Double>) -> Double {
        guard step > 0, value.isNaN == false else { return range.lowerBound }
        guard value.isFinite else { return value > 0 ? range.upperBound : range.lowerBound }
        let snapped = (value / step).rounded() * step
        return min(max(snapped, range.lowerBound), range.upperBound)
    }
}
