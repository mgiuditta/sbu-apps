import Foundation
import Testing
@testable import SbuSpeed

struct NavigationReadingTests {
    private let italian = Locale(identifier: "it_IT")
    private let american = Locale(identifier: "en_US")

    private func sample(
        speed: Double = 10,
        altitude: Double = 122,
        verticalAccuracy: Double = 5,
        course: Double = 247,
        courseAccuracy: Double = 5
    ) -> SpeedSample {
        SpeedSample(
            timestamp: .now, speed: speed, speedAccuracy: 0.5, latitude: 45.46, longitude: 9.19, horizontalAccuracy: 5,
            altitude: altitude, verticalAccuracy: verticalAccuracy, course: course, courseAccuracy: courseAccuracy
        )
    }

    @Test func goodFixGivesAltitudeAndCourse() {
        #expect(NavigationReading(sample: sample()) == NavigationReading(altitude: 122, course: 247))
    }

    @Test(arguments: [-1.0, 80])
    func uncertainAltitudeIsNotShown(verticalAccuracy: Double) {
        #expect(NavigationReading(sample: sample(verticalAccuracy: verticalAccuracy)).altitude == nil)
    }

    @Test(arguments: [
        // Standing still, no course, no course accuracy, a course too uncertain.
        (0.2, 247.0, 5.0),
        (10, -1, 5),
        (10, 247, -1),
        (10, 247, 60),
    ])
    func courseNeedsMovementAndAccuracy(speed: Double, course: Double, courseAccuracy: Double) {
        let reading = NavigationReading(sample: sample(speed: speed, course: course, courseAccuracy: courseAccuracy))

        #expect(reading.course == nil)
        #expect(reading.altitude == 122)
    }

    @Test func standingStillKeepsTheAltitude() {
        #expect(NavigationReading(sample: sample(speed: 0)).altitude == 122)
    }

    @Test(arguments: [
        (SpeedUnit.kilometersPerHour, "it_IT", "122 m"),
        (.milesPerHour, "en_US", "400 ft"),
        (.knots, "it_IT", "122 m"),
        (.knots, "en_US", "400 ft"),
    ])
    func altitudeFollowsTheUnit(unit: SpeedUnit, locale: String, expected: String) {
        let text = NavigationReading(altitude: 122).altitudeText(unit: unit, locale: Locale(identifier: locale))

        #expect(text.withPlainSpaces == expected)
    }

    @Test func missingValuesShowADash() {
        let reading = NavigationReading()

        #expect(reading.altitudeText(unit: .kilometersPerHour, locale: italian) == "–")
        #expect(reading.courseText(locale: italian) == "–")
    }

    @Test(arguments: [
        (247.0, "247° SW"),
        (0, "0° N"),
        (359.6, "0° N"),
        (90.4, "90° E"),
        (315, "315° NW"),
    ])
    func courseHasDegreesAndTheCompassPoint(degrees: Double, expected: String) {
        #expect(NavigationReading(course: degrees).courseText(locale: american) == expected)
    }

    @Test func courseIsSpokenInWords() {
        let spoken = NavigationReading(course: 247).courseSpokenText(locale: american)

        #expect(spoken == "247 degrees, south-west")
    }

    @Test func altitudeIsSpokenInWords() {
        let spoken = NavigationReading(altitude: 122).altitudeSpokenText(unit: .kilometersPerHour, locale: american)

        #expect(spoken.withPlainSpaces == "122 meters")
    }

    @Test(arguments: [
        (0.0, CompassPoint.north),
        (22.4, .north),
        (22.6, .northEast),
        (180, .south),
        (247, .southWest),
        (337.4, .northWest),
        (337.6, .north),
        (-90, .west),
        (720, .north),
    ])
    func compassPointIsTheSectorOfTheDegrees(degrees: Double, expected: CompassPoint) {
        #expect(CompassPoint(degrees: degrees) == expected)
    }
}
