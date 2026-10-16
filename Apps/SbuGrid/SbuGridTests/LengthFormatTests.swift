import Foundation
import Testing
@testable import SbuGrid

struct LengthFormatTests {
    let italian = Locale(identifier: "it_IT")
    let american = Locale(identifier: "en_US")

    @Test(arguments: [(2.0, "2"), (0.75, "0,75"), (29.7, "29,7"), (1.0 / 3.0, "0,33"), (100.0, "100")])
    func numbersHaveUpToTwoDecimals(value: Double, expected: String) {
        #expect(LengthFormat.number(value, locale: italian) == expected)
    }

    @Test func shortLengthsCarryTheSymbol() {
        #expect(LengthFormat.short(2, unit: .centimeters, locale: italian) == "2 cm")
        #expect(LengthFormat.short(0.75, unit: .inches, locale: american) == "0.75 in")
    }

    @Test func spokenLengthsAreWords() {
        #expect(LengthFormat.spoken(2, unit: .centimeters, locale: italian) == "2 centimetri")
        #expect(LengthFormat.spoken(1, unit: .inches, locale: american) == "1 inch")
    }

    @Test func sheetsAreWidthByHeight() {
        #expect(LengthFormat.sheet(width: 21, height: 29.7, unit: .centimeters, locale: italian) == "21 × 29,7 cm")
        #expect(LengthFormat.sheet(width: 8.5, height: 11, unit: .inches, locale: american) == "8.5 × 11 in")
    }

    @Test func symbols() {
        #expect(LengthFormat.symbol(.centimeters) == "cm")
        #expect(LengthFormat.symbol(.inches) == "in")
    }
}
