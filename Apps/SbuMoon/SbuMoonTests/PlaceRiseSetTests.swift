import Foundation
import Testing
@testable import SbuMoon

nonisolated struct PlaceRiseSetTests {
    private static let newYork = Coordinates(latitude: 40.7128, longitude: -74.0060)
    private static let rome = Coordinates(latitude: 41.8933, longitude: 12.4828)

    private static func calendar(_ identifier: String) throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: identifier))
        return calendar
    }

    @Test func aCityInAnotherZoneIsWorkedOutOnItsOwnClock() throws {
        // An iPhone in Rome shows 13 October 2026; New York's moon that day rises at 10:21 and
        // sets at 19:34 New York time (USNO), 16:21 and 01:34 in Rome.
        let phone = try Self.calendar("Europe/Rome")
        let shown = try Date("2026-10-13T10:00:00Z", strategy: .iso8601)
        let newYorkZone = try #require(TimeZone(identifier: "America/New_York"))

        let times = PlaceRiseSet(shownDate: shown, coordinates: Self.newYork, timeZone: newYorkZone, deviceCalendar: phone)

        #expect(times.timeZone == newYorkZone)
        #expect(times.isOtherTimeZone)
        guard case let .crosses(rise, set) = times.riseSet else {
            Issue.record("Expected a rise and a set, got \(times.riseSet)")
            return
        }
        let expectedRise = try Date("2026-10-13T14:21:00Z", strategy: .iso8601)
        let expectedSet = try Date("2026-10-13T23:34:00Z", strategy: .iso8601)
        #expect(abs(try #require(rise).timeIntervalSince(expectedRise)) <= 150)
        #expect(abs(try #require(set).timeIntervalSince(expectedSet)) <= 150)
    }

    @Test func theDayIsTheOneThePillShowsEvenAfterMidnightOnThePhone() throws {
        // 00:30 on 14 October in Rome is still 13 October in New York: the screen says the 14th,
        // so New York's 14th is worked out.
        let phone = try Self.calendar("Europe/Rome")
        let shown = try Date("2026-10-13T22:30:00Z", strategy: .iso8601)
        let newYorkZone = try #require(TimeZone(identifier: "America/New_York"))
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = newYorkZone

        let times = PlaceRiseSet(shownDate: shown, coordinates: Self.newYork, timeZone: newYorkZone, deviceCalendar: phone)

        guard case let .crosses(rise, _) = times.riseSet else {
            Issue.record("Expected a rise, got \(times.riseSet)")
            return
        }
        #expect(newYork.component(.day, from: try #require(rise)) == 14)
    }

    @Test func theIPhonesPositionStaysOnTheIPhonesClock() throws {
        let phone = try Self.calendar("Europe/Rome")
        let shown = try Date("2024-01-21T11:00:00Z", strategy: .iso8601)

        let times = PlaceRiseSet(shownDate: shown, coordinates: Self.rome, timeZone: nil, deviceCalendar: phone)

        #expect(times.timeZone == phone.timeZone)
        #expect(times.isOtherTimeZone == false)
    }

    @Test(arguments: [
        // Paris keeps Rome's clock; London is an hour behind; Lagos matches Rome only in winter.
        ("Europe/Paris", "2026-10-13T10:00:00Z", false),
        ("Europe/London", "2026-10-13T10:00:00Z", true),
        ("Europe/London", "2026-01-13T10:00:00Z", true),
        ("Africa/Lagos", "2026-01-13T10:00:00Z", false),
        ("Africa/Lagos", "2026-07-13T10:00:00Z", true),
    ])
    func saysWhichClockOnlyWhenItShowsAnotherTime(zone: String, shown: String, isOther: Bool) throws {
        let phone = try Self.calendar("Europe/Rome")
        let date = try Date(shown, strategy: .iso8601)

        let times = PlaceRiseSet(shownDate: date, coordinates: Self.rome, timeZone: TimeZone(identifier: zone), deviceCalendar: phone)

        #expect(times.isOtherTimeZone == isOther)
    }

    @Test func everyBundledCityHasAKnownZone() {
        #expect(CityCatalog.all.allSatisfy { TimeZone(identifier: $0.timeZone) != nil })
    }
}
