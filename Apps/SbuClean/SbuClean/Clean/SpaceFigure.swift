import Foundation

/// A number of bytes as the one figure of a screen: a short number and its unit apart.
///
/// GB from one gigabyte up, with one decimal under ten; MB below, whole. Units are decimal,
/// as in Settings → General → iPhone Storage, so the numbers match what iOS shows.
nonisolated struct SpaceFigure: Equatable, Sendable {
    let value: Double
    let unit: String
    let format: FloatingPointFormatStyle<Double>

    init(bytes: Int64) {
        let gigabytes = Double(bytes) / 1_000_000_000
        if gigabytes >= 1 {
            value = gigabytes
            unit = "GB"
            format = .number.precision(.fractionLength(gigabytes < 10 ? 1 : 0))
        } else {
            value = Double(bytes) / 1_000_000
            unit = "MB"
            format = .number.precision(.fractionLength(0))
        }
    }

    /// The number without its unit, in the current locale.
    var formattedValue: String {
        format.format(value)
    }
}
