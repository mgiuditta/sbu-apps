import Foundation

/// Formats the figure: a speed in metres per second as a whole number in the chosen unit,
/// or a dash when there is no speed yet. The unit symbol sits next to it, smaller.
nonisolated struct SpeedFigureStyle: FormatStyle {
    /// Shown while there is no GPS speed.
    static let noSpeed = "–"

    var unit: SpeedUnit
    var locale: Locale = .autoupdatingCurrent

    func format(_ metersPerSecond: Double?) -> String {
        guard let metersPerSecond else { return Self.noSpeed }
        return unit.value(ofMetersPerSecond: metersPerSecond)
            .formatted(.number.precision(.fractionLength(0)).locale(locale))
    }

    func locale(_ locale: Locale) -> SpeedFigureStyle {
        var style = self
        style.locale = locale
        return style
    }
}
