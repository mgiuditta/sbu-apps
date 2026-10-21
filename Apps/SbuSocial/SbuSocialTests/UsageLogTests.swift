import Foundation
import Testing
@testable import SbuSocial

struct UsageLogTests {
    private let defaults: UserDefaults
    private let calendar = Calendar(identifier: .gregorian)
    private let day = Date(timeIntervalSince1970: 1_792_000_000)

    init() {
        let suite = "UsageLogTests-\(UUID())"
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
    }

    private func log(at date: Date) -> UsageLog {
        UsageLog(defaults: defaults, calendar: calendar, now: { date })
    }

    @Test func secondsAddUpToMinutesPerPlatformAndInTotal() {
        let usage = log(at: day)
        usage.add(90, on: .instagram)
        usage.add(45, on: .youtube)
        #expect(usage.minutes(on: day, platform: .instagram) == 1)
        #expect(usage.minutes(on: day, platform: .youtube) == 0)
        #expect(usage.minutesToday == 2)
    }

    @Test func aNewDayStartsFromZero() throws {
        log(at: day).add(600, on: .instagram)
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: day))
        let next = log(at: tomorrow)
        #expect(next.minutesToday == 0)
        #expect(next.minutes(on: day) == 10)
    }

    @Test(arguments: [(0, 500, false), (30, 29, false), (30, 30, true), (15, 40, true)])
    func theLimitClosesOnceReached(limit: Int, minutes: Int, over: Bool) {
        let usage = log(at: day)
        usage.limitMinutes = limit
        usage.add(minutes * 60, on: .instagram)
        #expect(usage.isOverLimit == over)
    }

    @Test func timeAndLimitSurviveARelaunch() {
        let usage = log(at: day)
        usage.limitMinutes = 45
        usage.add(120, on: .instagram)
        usage.save()
        let relaunched = log(at: day)
        #expect(relaunched.minutesToday == 2)
        #expect(relaunched.limitMinutes == 45)
    }

    @Test func sevenDaysEndingToday() {
        let days = log(at: day).lastSevenDays
        #expect(days.count == 7)
        #expect(days.last == calendar.startOfDay(for: day))
    }
}

struct UsageAverageTests {
    @Test func theAverageSpreadsTheWeekOverSevenDays() throws {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date(timeIntervalSince1970: 1_792_000_000)
        let defaults = UserDefaults(suiteName: "UsageAverageTests-\(UUID())")!
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))
        UsageLog(defaults: defaults, calendar: calendar, now: { yesterday }).add(40 * 60, on: .instagram)
        let usage = UsageLog(defaults: defaults, calendar: calendar, now: { today })
        // Yesterday's minutes were saved only if a save came: add() saves the first time.
        usage.add(30 * 60, on: .youtube)
        #expect(usage.averageMinutes == 10)
    }
}
