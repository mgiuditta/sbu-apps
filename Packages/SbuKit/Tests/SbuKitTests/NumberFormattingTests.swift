import Foundation
import SwiftUI
import Testing
@testable import SbuKit

/// Figures use monospaced digits and follow the locale.
struct NumberFormattingTests {
    @Test func statFontsUseMonospacedDigits() {
        let stat = Font.system(size: 40, weight: .medium, design: .monospaced)
        let statSmall = Font.system(size: 22, weight: .medium, design: .monospaced)

        #expect(SbuTheme.stat == stat.monospacedDigit())
        #expect(SbuTheme.stat != stat)
        #expect(SbuTheme.statSmall == statSmall.monospacedDigit())
        #expect(SbuTheme.numberFont(size: 17) == Font.system(size: 17, weight: .medium, design: .monospaced).monospacedDigit())
    }

    @Test(arguments: [
        ("it_IT", 2.4, "2,4"),
        ("en_US", 2.4, "2.4"),
        ("it_IT", 0.0, "0,0"),
        ("it_IT", 1234.5, "1234,5"),
    ])
    func statFormatsDecimalsForLocale(identifier: String, value: Double, expected: String) {
        let format = FloatingPointFormatStyle<Double>.number
            .precision(.fractionLength(1))
            .grouping(.never)
            .locale(Locale(identifier: identifier))

        let stat = SbuStat("Inclinazione", value: value, format: format, unit: "°")

        #expect(stat.formattedValue == expected)
    }

    @Test func statFormatsCurrency() {
        let format = Decimal.FormatStyle.Currency(code: "EUR", locale: Locale(identifier: "it_IT"))
        let stat = SbuStat("Spesa mensile", value: Decimal(string: "128.90") ?? 0, format: format)

        // Foundation separates amount and symbol with a no-break space.
        #expect(stat.formattedValue == "128,90\u{00A0}€")
    }
}
