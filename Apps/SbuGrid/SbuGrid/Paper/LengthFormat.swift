import Foundation

/// Lengths as the app writes them: "2 cm", "0,75 in", "29,7 cm"; or in words for VoiceOver.
nonisolated enum LengthFormat {
    /// The number alone, with up to two decimals: "2", "0,75", "29,7".
    static func number(_ value: Double, locale: Locale = .autoupdatingCurrent) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)).locale(locale))
    }

    /// The number and the unit's symbol: "2 cm".
    static func short(_ value: Double, unit: LengthUnit, locale: Locale = .autoupdatingCurrent) -> String {
        Measurement(value: value, unit: unit.unitLength)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...2))).locale(locale))
    }

    /// The number and the unit in words, for VoiceOver: "2 centimetri".
    static func spoken(_ value: Double, unit: LengthUnit, locale: Locale = .autoupdatingCurrent) -> String {
        Measurement(value: value, unit: unit.unitLength)
            .formatted(.measurement(width: .wide, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...2))).locale(locale))
    }

    /// A sheet as width × height and unit: "21 × 29,7 cm".
    static func sheet(width: Double, height: Double, unit: LengthUnit, locale: Locale = .autoupdatingCurrent) -> String {
        "\(number(width, locale: locale)) × \(short(height, unit: unit, locale: locale))"
    }

    /// The symbol after the figure: "cm", "in".
    static func symbol(_ unit: LengthUnit) -> String {
        unit.unitLength.symbol
    }
}
