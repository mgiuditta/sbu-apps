import Foundation

/// How the moon's age and distance read on screen; both follow the locale.
nonisolated enum MoonDetailFormat {
    /// Age in days and hours, such as "9 giorni e 10 ore".
    static let age = Duration.UnitsFormatStyle(allowedUnits: [.days, .hours], width: .wide)

    /// Distance in whole kilometres, such as "368.410 km", whatever the region's usual unit:
    /// the moon's distance is given in kilometres everywhere.
    static let distance = Measurement<UnitLength>.FormatStyle(
        width: .abbreviated,
        usage: .asProvided,
        numberFormatStyle: .number.precision(.fractionLength(0))
    )
}
