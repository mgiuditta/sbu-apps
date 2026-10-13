import Foundation
import Testing
@testable import SbuMoon

/// Rise and set against the US Naval Observatory's published times (aa.usno.navy.mil, "Rise/Set/
/// Transit Times for One Day"), rounded to the minute in the place's standard or summer time.
nonisolated struct MoonRiseSetTests {
    private static let rome = Coordinates(latitude: 41.8933, longitude: 12.4828)
    private static let newYork = Coordinates(latitude: 40.7128, longitude: -74.0060)
    private static let london = Coordinates(latitude: 51.5074, longitude: -0.1278)
    private static let sydney = Coordinates(latitude: -33.8688, longitude: 151.2093)
    private static let longyearbyen = Coordinates(latitude: 78.2232, longitude: 15.6267)

    /// One published day: the date, the offset from UTC in hours, and "HH:mm" or nil when USNO
    /// lists no such event that day.
    struct Almanac: Sendable, CustomTestStringConvertible {
        var place: String
        var coordinates: Coordinates
        var day: String
        var utcOffset: Int
        var rise: String?
        var set: String?

        var testDescription: String { "\(place) \(day)" }
    }

    @Test(arguments: [
        Almanac(place: "Roma", coordinates: rome, day: "2024-01-21", utcOffset: 1, rise: "13:04", set: "04:08"),
        Almanac(place: "Roma", coordinates: rome, day: "2026-08-15", utcOffset: 2, rise: "09:20", set: "21:25"),
        Almanac(place: "New York", coordinates: newYork, day: "2025-03-14", utcOffset: -4, rise: "19:38", set: "07:18"),
        Almanac(place: "New York", coordinates: newYork, day: "2026-10-13", utcOffset: -4, rise: "10:21", set: "19:34"),
        Almanac(place: "Londra", coordinates: london, day: "2026-10-13", utcOffset: 1, rise: "10:58", set: "18:43"),
        Almanac(place: "Sydney", coordinates: sydney, day: "2025-12-04", utcOffset: 11, rise: "19:20", set: "04:17"),
        Almanac(place: "Longyearbyen", coordinates: longyearbyen, day: "2026-01-07", utcOffset: 1, rise: "19:56", set: "12:16"),
        Almanac(place: "Longyearbyen", coordinates: longyearbyen, day: "2026-01-09", utcOffset: 1, rise: nil, set: "09:40"),
        Almanac(place: "Longyearbyen", coordinates: longyearbyen, day: "2026-01-10", utcOffset: 1, rise: "02:06", set: "08:09"),
    ])
    func matchesTheAlmanacWithinTwoMinutes(_ almanac: Almanac) throws {
        let calendar = Self.calendar(utcOffset: almanac.utcOffset)
        let noon = try Self.date(almanac.day, "12:00", calendar: calendar)

        let result = MoonHorizon.riseSet(on: noon, at: almanac.coordinates, calendar: calendar)

        guard case let .crosses(rise, set) = result else {
            Issue.record("Expected a rise or a set, got \(result)")
            return
        }
        try Self.expect(rise, matches: almanac.rise, on: almanac.day, calendar: calendar)
        try Self.expect(set, matches: almanac.set, on: almanac.day, calendar: calendar)
    }

    @Test func staysUpAllDayInThePolarNight() throws {
        let calendar = Self.calendar(utcOffset: 1)
        let day = try Self.date("2026-01-03", "12:00", calendar: calendar)

        #expect(MoonHorizon.riseSet(on: day, at: Self.longyearbyen, calendar: calendar) == .aboveAllDay)
    }

    @Test func staysDownAllDayWhenItNeverRises() throws {
        let calendar = Self.calendar(utcOffset: 1)
        let day = try Self.date("2026-01-12", "12:00", calendar: calendar)

        #expect(MoonHorizon.riseSet(on: day, at: Self.longyearbyen, calendar: calendar) == .belowAllDay)
    }

    @Test func positionMatchesMeeusExample47a() {
        // 1992 April 12, 0h TD.
        let position = LunarPosition(julianCenturies: (2_448_724.5 - 2_451_545) / 36_525)

        #expect(abs(position.longitude - 133.167265) < 0.0005)
        #expect(abs(position.latitude - -3.229126) < 0.0001)
        #expect(abs(position.distance - 368_409.7) < 1)
        #expect(abs(position.rightAscension - 134.688470) < 0.0005)
        #expect(abs(position.declination - 13.768368) < 0.0005)
    }

    @Test func siderealTimeMatchesMeeusExample12a() throws {
        // 1987 April 10, 0h UT: mean 13h10m46.3668s, apparent 13h10m46.1351s.
        let midnight = try Date("1987-04-10T00:00:00Z", strategy: .iso8601)
        let nutation = -3.788 / 3_600
        let obliquity = 23.44357

        let degrees = MoonHorizon.apparentSiderealTime(at: midnight, nutation: nutation, obliquity: obliquity)

        let expected = (13 + 10.0 / 60 + 46.1351 / 3_600) * 15
        #expect(abs(degrees - expected) < 0.0001)
    }

    // MARK: Helpers

    private static func calendar(utcOffset: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: utcOffset * 3_600) ?? .gmt
        return calendar
    }

    private static func date(_ day: String, _ time: String, calendar: Calendar) throws -> Date {
        let parts = (day.split(separator: "-") + time.split(separator: ":")).compactMap { Int($0) }
        let components = DateComponents(year: parts[0], month: parts[1], day: parts[2], hour: parts[3], minute: parts[4])
        return try #require(calendar.date(from: components))
    }

    private static func expect(_ computed: Date?, matches published: String?, on day: String, calendar: Calendar) throws {
        guard let published else {
            #expect(computed == nil)
            return
        }
        let computed = try #require(computed)
        let expected = try date(day, published, calendar: calendar)
        // The almanac rounds to the minute: two minutes of our error plus half a minute of its rounding.
        #expect(abs(computed.timeIntervalSince(expected)) <= 150, "\(computed) vs \(expected)")
    }
}
