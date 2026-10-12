import Foundation
import Testing
@testable import SbuMoon

struct MoonDetailsTests {
    private let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    private func date(_ iso: String) throws -> Date {
        try Date(iso, strategy: .iso8601)
    }

    // MARK: Distance

    @Test func distanceMatchesMeeusExample47a() {
        // 1992 April 12, 0h TD: T = −0.077221081451, Δ = 368 409.7 km.
        let arguments = LunarArguments(julianCenturies: -0.077_221_081_451)

        #expect(abs(MoonDistance.kilometres(arguments: arguments) - 368_409.7) < 0.1)
    }

    @Test func argumentsMatchMeeusExample47a() {
        let arguments = LunarArguments(julianCenturies: -0.077_221_081_451)

        #expect(abs(arguments.elongation.reducedDegrees - 113.842_304) < 0.000_01)
        #expect(abs(arguments.sunAnomaly.reducedDegrees - 97.643_514) < 0.000_01)
        #expect(abs(arguments.moonAnomaly.reducedDegrees - 5.150_833) < 0.000_01)
        #expect(abs(arguments.latitude.reducedDegrees - 219.889_721) < 0.000_01)
        #expect(abs(arguments.eccentricity - 1.000_194) < 0.000_001)
    }

    @Test func distanceAtADateMatchesMeeusExample47a() {
        let jde = 2_448_724.5
        let instant = MoonAstronomy.date(julianDay: jde - MoonAstronomy.deltaT(julianDay: jde) / 86_400)

        #expect(abs(MoonDistance.kilometres(at: instant) - 368_409.7) < 1)
    }

    @Test func distanceStaysBetweenPerigeeAndApogeeForAYear() throws {
        let start = try date("2024-01-01T00:00:00Z")
        let distances = (0..<(366 * 4)).map { MoonDistance.kilometres(at: start.addingTimeInterval(Double($0) * 21_600)) }

        let nearest = try #require(distances.min())
        let farthest = try #require(distances.max())
        #expect(nearest > 356_000 && nearest < 360_000)
        #expect(farthest > 405_000 && farthest < 407_000)
    }

    // MARK: Age

    @Test func ageCountsFromTheLastNewMoon() throws {
        // New moon 11 January 2024 11:57 UTC.
        let reading = MoonReading(date: try date("2024-01-21T06:00:00Z"), calendar: utc)

        let expected = Duration.seconds(9 * 86_400 + 18 * 3_600 + 3 * 60)
        #expect(abs((reading.age - expected) / .seconds(1)) < 120)
    }

    @Test func ageIsZeroAtNewMoonAndALunationJustBefore() throws {
        let newMoon = MoonAstronomy.next(.new, after: try date("2024-04-01T00:00:00Z"))

        let atNewMoon = MoonReading(date: newMoon, calendar: utc)
        let justBefore = MoonReading(date: newMoon.addingTimeInterval(-60), calendar: utc)

        #expect(atNewMoon.age == .zero)
        #expect(justBefore.age > .seconds(29 * 86_400))
        #expect(justBefore.age < .seconds(MoonAstronomy.synodicMonth * 86_400 + 86_400))
    }

    // MARK: Format

    @Test(arguments: [("it_IT", "9 giorni e 10 ore"), ("en_US", "9 days, 10 hours")])
    func ageReadsInDaysAndHours(identifier: String, expected: String) {
        let age = Duration.seconds(9 * 86_400 + 10 * 3_600 + 20 * 60)

        #expect(age.formatted(MoonDetailFormat.age.locale(Locale(identifier: identifier))).plainSpaces == expected)
    }

    @Test(arguments: [("it_IT", "368.410 km"), ("en_US", "368,410 km"), ("en_GB", "368,410 km")])
    func distanceReadsInWholeKilometres(identifier: String, expected: String) {
        let distance = Measurement(value: 368_409.7, unit: UnitLength.kilometers)

        #expect(distance.formatted(MoonDetailFormat.distance.locale(Locale(identifier: identifier))).plainSpaces == expected)
    }
}

private extension Double {
    /// The angle in 0..<360 degrees.
    var reducedDegrees: Double {
        let remainder = truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }
}

private extension String {
    /// The string with the narrow and non-breaking spaces of number formats as plain spaces.
    var plainSpaces: String {
        replacing("\u{202F}", with: " ").replacing("\u{00A0}", with: " ")
    }
}
