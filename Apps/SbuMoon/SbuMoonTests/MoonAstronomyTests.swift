import Foundation
import Testing
@testable import SbuMoon

struct MoonAstronomyTests {
    /// Phase instants published by the US Naval Observatory, to the minute (UTC).
    @Test(arguments: [
        (PrincipalPhase.new, "2023-04-20T04:12:00Z"),
        (.new, "2024-04-08T18:21:00Z"),
        (.new, "2025-01-29T12:36:00Z"),
        (.full, "2022-11-08T11:02:00Z"),
        (.full, "2024-01-25T17:54:00Z"),
        (.full, "2024-09-18T02:34:00Z"),
        (.full, "2025-03-14T06:55:00Z"),
        (.firstQuarter, "2024-01-18T03:52:00Z"),
        (.lastQuarter, "2024-02-02T23:18:00Z"),
    ])
    func phaseInstantMatchesTheAlmanacWithinTwoMinutes(phase: PrincipalPhase, expected: String) throws {
        let reference = try Date(expected, strategy: .iso8601)

        let instant = MoonAstronomy.next(phase, after: reference.addingTimeInterval(-3 * 86_400))

        #expect(abs(instant.timeIntervalSince(reference)) < 120)
    }

    @Test func newMoonMatchesMeeusExample49a() {
        // February 1977, k = −283: JDE 2443192.65118.
        let instant = MoonAstronomy.instant(of: .new, lunation: -283)
        let julianDay = MoonAstronomy.julianDay(of: instant)

        let jde = julianDay + MoonAstronomy.deltaT(julianDay: julianDay) / 86_400

        #expect(abs(jde - 2_443_192.65118) < 0.0001)
    }

    @Test func illuminationMatchesMeeusExample48a() {
        // 1992 April 12, 0h TD: k = 0.6786.
        let jde = 2_448_724.5
        let date = MoonAstronomy.date(julianDay: jde - MoonAstronomy.deltaT(julianDay: jde) / 86_400)

        #expect(abs(MoonAstronomy.illuminatedFraction(at: date) - 0.6786) < 0.003)
    }

    @Test func julianDayOfJ2000() throws {
        let noon = try Date("2000-01-01T12:00:00Z", strategy: .iso8601)

        #expect(MoonAstronomy.julianDay(of: noon) == 2_451_545)
        #expect(MoonAstronomy.date(julianDay: 2_451_545) == noon)
    }

    @Test(arguments: [(2000.0, 63.9), (2024.0, 73.9), (2050.0, 93)])
    func deltaTFollowsTheEspenakMeeusPolynomials(year: Double, expected: Double) {
        let julianDay = 2_451_545 + (year - 2000) * 365.25

        #expect(abs(MoonAstronomy.deltaT(julianDay: julianDay) - expected) < 1.5)
    }

    @Test func eventsAreInOrderAndCycleThroughThePhases() {
        let events = MoonAstronomy.events(around: .now)

        #expect(events.count == 20)
        #expect(zip(events, events.dropFirst()).allSatisfy { $0.date < $1.date })
        #expect(events.prefix(4).map(\.phase) == PrincipalPhase.allCases)
    }

    @Test func nextIsStrictlyAfterTheDate() throws {
        let fullMoon = MoonAstronomy.next(.full, after: try Date("2024-01-20T00:00:00Z", strategy: .iso8601))

        let following = MoonAstronomy.next(.full, after: fullMoon)

        #expect(following > fullMoon)
        #expect(abs(following.timeIntervalSince(fullMoon) / 86_400 - MoonAstronomy.synodicMonth) < 1)
    }
}
