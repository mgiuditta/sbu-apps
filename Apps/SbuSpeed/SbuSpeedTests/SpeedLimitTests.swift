import Foundation
import Testing
@testable import SbuSpeed

struct SpeedLimitTests {
    /// Metres per second for a speed in km/h.
    private func kmh(_ value: Double) -> Double { value / 3.6 }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, [20, 25, 30, 50, 70, 90, 110, 130]),
        (.milesPerHour, [15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80]),
        (.knots, [3, 5, 6, 8, 10, 12, 15, 20]),
    ])
    func presetsAreTheUsualLimits(unit: SpeedUnit, expected: [Int]) {
        let presets = SpeedLimit.presets(for: unit)

        #expect(presets.map(\.value) == expected)
        #expect(presets.allSatisfy { $0.unit == unit })
    }

    @Test(arguments: [
        (49.0, false),
        (50.0, false),
        // The figure is a whole number: 50.4 still shows 50.
        (50.4, false),
        (50.6, true),
        (90.0, true),
    ])
    func exceededOnlyWhenTheFigureIsAbove(kilometersPerHour: Double, expected: Bool) {
        let limit = SpeedLimit(value: 50, unit: .kilometersPerHour)

        #expect(limit.isExceeded(byMetersPerSecond: kmh(kilometersPerHour)) == expected)
    }

    @Test(arguments: [
        (SpeedLimit(value: 50, unit: .kilometersPerHour), SpeedUnit.milesPerHour, 30),
        (SpeedLimit(value: 130, unit: .kilometersPerHour), .milesPerHour, 80),
        (SpeedLimit(value: 30, unit: .milesPerHour), .kilometersPerHour, 50),
        (SpeedLimit(value: 70, unit: .milesPerHour), .kilometersPerHour, 110),
        (SpeedLimit(value: 90, unit: .kilometersPerHour), .kilometersPerHour, 90),
        // 10 kn is 18.5 km/h: 20 is within a tenth.
        (SpeedLimit(value: 10, unit: .knots), .kilometersPerHour, 20),
        // No preset within a tenth: the value itself. 50 km/h is 27 kn, 130 km/h is 70 kn, 10 kn is 11.5 mph.
        (SpeedLimit(value: 50, unit: .kilometersPerHour), .knots, 27),
        (SpeedLimit(value: 130, unit: .kilometersPerHour), .knots, 70),
        (SpeedLimit(value: 10, unit: .knots), .milesPerHour, 12),
        (SpeedLimit(value: 30, unit: .milesPerHour), .knots, 26),
        (SpeedLimit(value: 3, unit: .knots), .kilometersPerHour, 6),
    ])
    func convertsToTheNearestPresetOrTheValue(limit: SpeedLimit, unit: SpeedUnit, expected: Int) {
        #expect(limit.converted(to: unit) == SpeedLimit(value: expected, unit: unit))
    }

    @Test(arguments: [
        (SpeedLimit(value: 50, unit: .kilometersPerHour), "50 km/h"),
        (SpeedLimit(value: 30, unit: .milesPerHour), "30 mph"),
        (SpeedLimit(value: 5, unit: .knots), "5 kn"),
    ])
    func textCarriesTheUnit(limit: SpeedLimit, expected: String) {
        #expect(limit.text(locale: Locale(identifier: "en_US")).withPlainSpaces == expected)
    }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, "it_IT", [50, 90, 110, 130]),
        (.milesPerHour, "en_US", [25, 55, 65, 70]),
        (.milesPerHour, "en_GB", [20, 30, 60, 70]),
        (.knots, "it_IT", [3, 6, 10, 20]),
    ])
    func quickPresetsFollowTheUnitAndTheRegion(unit: SpeedUnit, locale: String, expected: [Int]) {
        let presets = SpeedLimit.quickPresets(for: unit, region: Locale(identifier: locale).region)

        #expect(presets.map(\.value) == expected)
        #expect(presets.allSatisfy { $0.unit == unit })
    }

    @Test(arguments: [
        ("45", Optional(45)),
        (" 7 ", 7),
        ("1", 1),
        ("300", 300),
        ("0", nil),
        ("301", nil),
        ("", nil),
        ("5,5", nil),
    ])
    func customValueIsAWholeNumberWithinTheDial(text: String, expected: Int?) {
        #expect(SpeedLimit.custom(text, unit: .kilometersPerHour)?.value == expected)
    }

    @Test func customValueStopsAtTheDialOfTheUnit() {
        #expect(SpeedLimit.custom("160", unit: .knots)?.value == 160)
        #expect(SpeedLimit.custom("161", unit: .knots) == nil)
    }

    @Test(arguments: [(3, 1.0), (10, 1), (20, 2), (25, 2.5), (50, 3), (130, 3)])
    func rearmMarginIsATenthBetweenOneAndThree(value: Int, expected: Double) {
        #expect(SpeedLimit(value: value, unit: .knots).rearmMargin == expected)
    }
}
