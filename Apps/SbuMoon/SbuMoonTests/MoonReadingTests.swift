import Foundation
import Testing
@testable import SbuMoon

struct MoonReadingTests {
    private let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    private func date(_ iso: String) throws -> Date {
        try Date(iso, strategy: .iso8601)
    }

    @Test(arguments: ["2022-11-08T11:02:00Z", "2024-01-25T17:54:00Z", "2025-03-14T06:55:00Z"])
    func fullMoonIsAlmostFullyLit(instant: String) throws {
        let reading = MoonReading(date: try date(instant), calendar: utc)

        #expect(reading.illumination > 0.99)
        #expect(reading.phase == .full)
    }

    @Test(arguments: ["2023-04-20T04:12:00Z", "2024-04-08T18:21:00Z", "2025-01-29T12:36:00Z"])
    func newMoonIsAlmostDark(instant: String) throws {
        let reading = MoonReading(date: try date(instant), calendar: utc)

        #expect(reading.illumination < 0.01)
        #expect(reading.phase == .new)
    }

    /// January 2024: new moon on the 11th, first quarter on the 18th, full on the 25th, last quarter on February 2nd.
    @Test(arguments: [
        ("2024-01-09T12:00:00Z", MoonPhase.waningCrescent),
        ("2024-01-11T00:30:00Z", .new),
        ("2024-01-11T23:30:00Z", .new),
        ("2024-01-14T12:00:00Z", .waxingCrescent),
        ("2024-01-18T20:00:00Z", .firstQuarter),
        ("2024-01-21T06:00:00Z", .waxingGibbous),
        ("2024-01-25T01:00:00Z", .full),
        ("2024-01-29T12:00:00Z", .waningGibbous),
        ("2024-02-02T08:00:00Z", .lastQuarter),
        ("2024-02-05T12:00:00Z", .waningCrescent),
    ])
    func phaseNamesThePrincipalPhaseForItsWholeDay(instant: String, expected: MoonPhase) throws {
        #expect(MoonReading.phase(at: try date(instant), calendar: utc) == expected)
    }

    @Test func principalPhaseDayFollowsTheCalendarsTimeZone() throws {
        // Full moon at 17:54 UTC on 25 January 2024 is 02:54 on the 26th in Tokyo.
        var tokyo = utc
        tokyo.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let evening = try date("2024-01-25T12:00:00Z") // 21:00 on the 25th in Tokyo

        #expect(MoonReading.phase(at: evening, calendar: utc) == .full)
        #expect(MoonReading.phase(at: evening, calendar: tokyo) == .waxingGibbous)
    }

    @Test func nextFullAndNewMoonComeAfterTheDate() throws {
        let reading = MoonReading(date: try date("2024-01-25T18:00:00Z"), calendar: utc)

        // Full moon 24 February 2024 12:30 UTC, new moon 9 February 2024 22:59 UTC.
        #expect(abs(reading.nextFullMoon.timeIntervalSince(try date("2024-02-24T12:30:00Z"))) < 120)
        #expect(abs(reading.nextNewMoon.timeIntervalSince(try date("2024-02-09T22:59:00Z"))) < 120)
    }

    @Test(arguments: [("2024-01-14T12:00:00Z", true), ("2024-01-21T06:00:00Z", true), ("2024-01-29T12:00:00Z", false), ("2024-02-05T12:00:00Z", false)])
    func discIsLitOnTheWaxingOrWaningSide(instant: String, isWaxing: Bool) throws {
        let reading = MoonReading(date: try date(instant), calendar: utc)

        #expect(reading.isWaxing == isWaxing)
        #expect(reading.disc == MoonDisc(illumination: reading.illumination, isWaxing: isWaxing))
    }

    @Test(arguments: ["it_IT", "en_US"])
    func illuminationIsAWholePercent(identifier: String) {
        let format = FloatingPointFormatStyle<Double>.Percent.percent.precision(.fractionLength(0)).locale(Locale(identifier: identifier))

        #expect(0.6786.formatted(format) == "68%")
    }
}
