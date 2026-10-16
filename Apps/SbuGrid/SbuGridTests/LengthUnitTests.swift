import Foundation
import Testing
@testable import SbuGrid

struct LengthUnitTests {
    @Test func anInchIsTwoAndAHalfCentimetres() {
        #expect(LengthUnit.inches.centimeters == 2.54)
        #expect(LengthUnit.centimeters.centimeters == 1)
    }

    @Test func pointsAreSeventyTwoToTheInch() {
        #expect(LengthUnit.inches.points == 72)
        #expect(abs(LengthUnit.centimeters.points - 28.346_456_692_9) < 1e-9)
    }

    @Test(arguments: [("it_IT", LengthUnit.centimeters), ("en_US", .inches), ("en_GB", .centimeters), ("de_DE", .centimeters), ("es_US", .inches)])
    func picksTheUnitOfTheRegion(locale: String, expected: LengthUnit) {
        #expect(LengthUnit.preferred(for: Locale(identifier: locale)) == expected)
    }

    @Test(arguments: [
        (2.0, 0.5, 2.0),
        (2.2, 0.5, 2.0),
        (2.25, 0.5, 2.5),
        (0.1, 0.5, 0.5),
        (99.0, 0.5, 10.0),
        (-3.0, 0.5, 0.5),
    ])
    func snapsToTheStepWithinTheRange(value: Double, step: Double, expected: Double) {
        #expect(LengthUnit.snap(value, step: step, within: 0.5...10) == expected)
    }

    @Test func absurdValuesSnapToABound() {
        #expect(LengthUnit.snap(.nan, step: 0.5, within: 1...10) == 1)
        #expect(LengthUnit.snap(.infinity, step: 0.5, within: 1...10) == 10)
        #expect(LengthUnit.snap(-.infinity, step: 0.5, within: 1...10) == 1)
        #expect(LengthUnit.snap(3, step: 0, within: 1...10) == 1)
        #expect(LengthUnit.snap(3, step: -1, within: 1...10) == 1)
    }

    @Test(arguments: [
        // 2 cm is 0.787 in: the nearest quarter is ¾.
        (2.0, LengthUnit.centimeters, LengthUnit.inches, 0.75),
        (1.0, .inches, .centimeters, 2.5),
        (0.75, .inches, .centimeters, 2.0),
        (10.0, .centimeters, .inches, 4.0),
        (0.5, .centimeters, .inches, 0.25),
        (2.0, .centimeters, .centimeters, 2.0),
    ])
    func convertsCellsOntoTheNewStep(value: Double, from: LengthUnit, to: LengthUnit, expected: Double) {
        #expect(from.convert(value, to: to, within: to.cellRange) == expected)
    }

    @Test(arguments: LengthUnit.allCases)
    func rangesStartAndEndOnAStep(unit: LengthUnit) {
        for bound in [unit.cellRange.lowerBound, unit.cellRange.upperBound, unit.sideRange.lowerBound, unit.sideRange.upperBound] {
            #expect((bound / unit.step).rounded() * unit.step == bound)
        }
        #expect(unit.cellRange.upperBound < unit.sideRange.upperBound)
    }
}
