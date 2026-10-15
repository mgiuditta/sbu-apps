import Foundation
import Testing
@testable import SbuLevel

struct AngleUnitTests {
    @Test(arguments: [
        (AngleUnit.degrees, 0.0, 0.0), (.degrees, 45, 45), (.degrees, 90, 90), (.degrees, -12.34, -12.3), (.degrees, 32.45, 32.5),
        (.wholeDegrees, 0, 0), (.wholeDegrees, 45, 45), (.wholeDegrees, 90, 90), (.wholeDegrees, 32.5, 33), (.wholeDegrees, -7.4, -7),
        (.percent, 0, 0), (.percent, 45, 100), (.percent, -45, -100), (.percent, 10, 17.6), (.percent, 89.9, 57295.7),
        (.pitch, 0, 0), (.pitch, 45, 12), (.pitch, -45, -12), (.pitch, 26.57, 6),
        (.ratio, 45, 1), (.ratio, -45, -1), (.ratio, 90, 0), (.ratio, 30, 1.7), (.ratio, 0.1, 573),
    ])
    func convertsDegreesToTheUnit(unit: AngleUnit, degrees: Double, expected: Double) throws {
        let value = try #require(unit.value(forDegrees: degrees))

        #expect(abs(value - expected) < 1e-9)
    }

    @Test(arguments: [
        (AngleUnit.percent, 90.0), (.percent, -90), (.percent, 89.96), (.pitch, 90), (.pitch, -90),
        (.ratio, 0), (.ratio, 0.04), (.ratio, -0.04),
    ])
    func hasNoValueWhereTheSlopeIsInfinite(unit: AngleUnit, degrees: Double) {
        #expect(unit.value(forDegrees: degrees) == nil)
    }

    @Test(arguments: AngleUnit.allCases)
    func neverShowsMinusZero(unit: AngleUnit) {
        let value = unit.value(forDegrees: unit == .ratio ? -90 : -0.001)

        #expect(value?.sign == .plus)
    }

    @Test(arguments: [
        (AngleUnit.degrees, 32.4, "32,4"), (.wholeDegrees, 32.4, "32"), (.percent, 45, "100,0"),
        (.percent, 89.9, "57.295,7"), (.percent, 90, "—"), (.pitch, 45, "12,0"), (.ratio, 30, "1:1,7"),
        (.ratio, 0, "—"), (.degrees, -3.25, "-3,3"),
    ])
    func formatsTheFigureWithoutItsSymbolInItalian(unit: AngleUnit, degrees: Double, expected: String) {
        let style = AngleFormatStyle(unit: unit, locale: Locale(identifier: "it_IT"))

        #expect(style.format(degrees) == expected)
    }

    @Test func formatsWithTheLocaleSeparator() {
        #expect(AngleFormatStyle(unit: .ratio, locale: Locale(identifier: "en_US")).format(30) == "1:1.7")
    }

    @Test(arguments: [(32.4, AngleUnit.degrees, "32,4 gradi"), (1, .wholeDegrees, "1 grado")])
    func spellsDegreesOutInTheLocale(degrees: Double, unit: AngleUnit, expected: String) {
        let style = AngleFormatStyle(unit: unit, locale: Locale(identifier: "it_IT"))

        #expect(style.spokenText(degrees) == expected)
    }

    /// The words come from the app's language, the one the test host runs in: only the figure is fixed.
    @Test(arguments: [(AngleUnit.percent, 45.0, "100,0"), (.pitch, 45, "12,0"), (.ratio, 30, "1,7")])
    func spellsTheOtherUnitsOutWithoutSymbols(unit: AngleUnit, degrees: Double, figure: String) {
        let spoken = AngleFormatStyle(unit: unit, locale: Locale(identifier: "it_IT")).spokenText(degrees)

        #expect(spoken.contains(figure))
        #expect(spoken.contains("%") == false)
        #expect(spoken.contains(":") == false)
    }

    @Test func offScaleIsSaidNotDashed() {
        #expect(AngleFormatStyle(unit: .percent).spokenText(90) != AngleFormatStyle.noValue)
    }

    @Test(arguments: AngleUnit.allCases)
    func everyUnitHasASymbolOrCarriesItInTheFigure(unit: AngleUnit) {
        #expect((unit.symbol == nil) == (unit == .ratio))
    }
}
