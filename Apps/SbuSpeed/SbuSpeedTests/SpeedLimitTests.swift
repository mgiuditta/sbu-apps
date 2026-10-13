import Foundation
import Testing
@testable import SbuSpeed

struct SpeedLimitTests {
    /// Metres per second for a speed in km/h.
    private func kmh(_ value: Double) -> Double { value / 3.6 }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, [30, 50, 70, 90, 110, 130]),
        (.milesPerHour, [20, 30, 40, 50, 60, 70, 80]),
        (.knots, [5, 10, 15, 20, 25, 30]),
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
        // 50 km/h is 27 kn, 130 km/h is 70 kn: beyond the presets, the highest one.
        (SpeedLimit(value: 50, unit: .kilometersPerHour), .knots, 25),
        (SpeedLimit(value: 130, unit: .kilometersPerHour), .knots, 30),
        (SpeedLimit(value: 10, unit: .knots), .kilometersPerHour, 30),
        (SpeedLimit(value: 10, unit: .knots), .milesPerHour, 20),
        (SpeedLimit(value: 30, unit: .milesPerHour), .knots, 25),
    ])
    func convertsToTheNearestPresetOfTheOtherUnit(limit: SpeedLimit, unit: SpeedUnit, expected: Int) {
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
}
