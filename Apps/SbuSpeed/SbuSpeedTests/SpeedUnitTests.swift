import Foundation
import Testing
@testable import SbuSpeed

struct SpeedUnitTests {
    @Test(arguments: [
        ("it_IT", SpeedUnit.kilometersPerHour),
        ("de_DE", .kilometersPerHour),
        ("en_US", .milesPerHour),
        ("en_GB", .milesPerHour),
    ])
    func defaultUnitFollowsTheRegion(identifier: String, expected: SpeedUnit) {
        #expect(SpeedUnit.preferred(for: Locale(identifier: identifier)) == expected)
    }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, 10.0, 36.0),
        (.milesPerHour, 10.0, 22.369),
        (.knots, 10.0, 19.438),
    ])
    func convertsFromMetersPerSecond(unit: SpeedUnit, metersPerSecond: Double, expected: Double) {
        #expect(abs(unit.value(ofMetersPerSecond: metersPerSecond) - expected) < 0.001)
    }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, "it_IT", "87 km/h"),
        (.kilometersPerHour, "en_US", "87 km/h"),
        (.milesPerHour, "en_US", "54 mph"),
        (.knots, "it_IT", "47 kn"),
        (.knots, "en_US", "47 kn"),
    ])
    func speedIsAWholeNumberWithItsUnit(unit: SpeedUnit, identifier: String, expected: String) {
        // 87 km/h, 54 mph, 47 kn.
        let text = unit.speedText(metersPerSecond: 24.1667, locale: Locale(identifier: identifier))

        #expect(text.withPlainSpaces == expected)
    }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, "it_IT", "12,4 km"),
        (.kilometersPerHour, "en_US", "12.4 km"),
        (.milesPerHour, "en_US", "7.7 mi"),
        // Knots go with nautical miles: 12.4 km is 6.7 nmi.
        (.knots, "it_IT", "6,7 nmi"),
        (.knots, "en_US", "6.7 nmi"),
    ])
    func distanceHasOneDecimalInTheMatchingUnit(unit: SpeedUnit, identifier: String, expected: String) {
        let text = unit.distanceText(meters: 12_400, locale: Locale(identifier: identifier))

        #expect(text.withPlainSpaces == expected)
    }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, 14.44, "52"),
        (.milesPerHour, 14.44, "32"),
        (.kilometersPerHour, 0, "0"),
        (.kilometersPerHour, 50, "180"),
        (.knots, 14.44, "28"),
    ])
    func figureIsTheWholeNumberAlone(unit: SpeedUnit, metersPerSecond: Double, expected: String) {
        let style = SpeedFigureStyle(unit: unit).locale(Locale(identifier: "it_IT"))

        #expect(style.format(metersPerSecond) == expected)
    }

    @Test func figureIsADashWithoutASpeed() {
        #expect(SpeedFigureStyle(unit: .kilometersPerHour).format(nil) == SpeedFigureStyle.noSpeed)
    }

    @Test func thousandsAreGroupedForTheLocale() {
        let style = SpeedFigureStyle(unit: .kilometersPerHour)

        // 300 m/s is 1080 km/h, grouped as the locale does.
        #expect(style.locale(Locale(identifier: "en_US")).format(300) == "1,080")
    }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, 0.0, 60.0),
        (.kilometersPerHour, 60, 60),
        (.kilometersPerHour, 61, 120),
        (.kilometersPerHour, 130, 200),
        (.kilometersPerHour, 250, 300),
        (.kilometersPerHour, 400, 300),
        (.milesPerHour, 0, 40),
        (.milesPerHour, 41, 80),
        (.milesPerHour, 90, 130),
        (.milesPerHour, 150, 200),
        (.milesPerHour, 260, 200),
        (.knots, 0, 30),
        (.knots, 31, 60),
        (.knots, 70, 110),
        (.knots, 150, 160),
        (.knots, 200, 160),
    ])
    func dialUsesTheSmallestScaleThatHoldsTheSpeed(unit: SpeedUnit, value: Double, expected: Double) {
        #expect(unit.fullScale(containing: value) == expected)
    }
}
