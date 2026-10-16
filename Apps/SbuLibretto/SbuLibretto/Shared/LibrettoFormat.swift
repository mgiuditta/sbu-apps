import Foundation

/// How the app writes its numbers, in the phone's language: "28,58" in Italian, "28.58" in English.
nonisolated enum LibrettoFormat {
    /// An average or a base, always with two decimals, as on a libretto.
    static let average = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(2))

    /// A change of the average, with its sign: "+0,26", "−0,13".
    static let change = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(2)).sign(strategy: .always(includingZero: false))

    /// Credits, with decimals only when there are any: "6", "7,5".
    static let credits = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0...2))

    /// A base of the degree grade: whole when it is whole, two decimals otherwise.
    static func base(_ value: Double) -> String {
        value.rounded() == value ? value.formatted(.number.precision(.fractionLength(0))) : value.formatted(average)
    }
}
