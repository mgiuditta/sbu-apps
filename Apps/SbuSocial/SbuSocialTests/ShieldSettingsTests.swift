import Foundation
import Testing
@testable import SbuSocial

struct ShieldSettingsTests {
    private let now = Date(timeIntervalSince1970: 1_792_000_000)
    private let calendar = Calendar(identifier: .gregorian)

    @Test func offAndEmptyUntilYouChoose() {
        let defaults = UserDefaults(suiteName: "ShieldSettingsTests-\(UUID())")!
        let settings = ShieldSettings.load(from: defaults)
        #expect(!settings.isOn)
        #expect(settings.appCount == 0)
        #expect(!settings.isShielding(now: now))
    }

    @Test func everythingSurvivesARelaunch() {
        let defaults = UserDefaults(suiteName: "ShieldSettingsTests-\(UUID())")!
        var settings = ShieldSettings()
        settings.isOn = true
        settings.sleep.isOn = true
        settings.focusEnd = now
        settings.save(to: defaults)
        #expect(ShieldSettings.load(from: defaults) == settings)
    }

    nonisolated struct Case: Sendable, CustomTestStringConvertible {
        var isOn = false
        var sleeping = false
        var focusIn: TimeInterval?
        var limitToday = false
        var postIn: TimeInterval?
        let up: Bool
        let testDescription: String
    }

    nonisolated static let cases: [Case] = [
        Case(up: false, testDescription: "nothing holds it"),
        Case(isOn: true, up: true, testDescription: "the switch"),
        Case(sleeping: true, up: true, testDescription: "the night"),
        Case(focusIn: 60, up: true, testDescription: "a running focus"),
        Case(focusIn: -60, up: false, testDescription: "a finished focus"),
        Case(limitToday: true, up: true, testDescription: "today's limit"),
        Case(isOn: true, sleeping: true, focusIn: 60, limitToday: true, postIn: 300, up: false, testDescription: "Modalità post beats everything"),
        Case(isOn: true, postIn: -1, up: true, testDescription: "a finished Modalità post"),
    ]

    @Test(arguments: cases)
    func whyTheShieldIsUp(_ test: Case) {
        var settings = ShieldSettings()
        settings.isOn = test.isOn
        settings.isSleeping = test.sleeping
        settings.focusEnd = test.focusIn.map(now.addingTimeInterval)
        settings.limitDay = test.limitToday ? ShieldSettings.day(now, calendar: calendar) : nil
        settings.postModeEnd = test.postIn.map(now.addingTimeInterval)
        #expect(settings.isShielding(now: now, calendar: calendar) == test.up)
    }

    @Test func yesterdaysLimitNoLongerHolds() throws {
        var settings = ShieldSettings()
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: now))
        settings.limitDay = ShieldSettings.day(yesterday, calendar: calendar)
        #expect(!settings.isShielding(now: now, calendar: calendar))
    }
}

struct SleepSettingsTests {
    @Test(arguments: [(1380, 420, 28800), (1350, 405, 29700), (60, 540, 28800)] as [(Int, Int, Int)])
    func durationCrossesMidnight(bedtime: Int, wake: Int, seconds: Int) {
        var sleep = SleepSettings()
        sleep.bedtime = bedtime
        sleep.wake = wake
        #expect(sleep.duration == .seconds(seconds))
    }

    @Test func theScheduleTakesTheMarginAndRepeatsWithAWarning() {
        var sleep = SleepSettings()
        sleep.bedtime = 23 * 60
        sleep.wake = 7 * 60
        sleep.margin = 30
        let schedule = sleep.schedule
        #expect(schedule.intervalStart.hour == 22 && schedule.intervalStart.minute == 30)
        #expect(schedule.intervalEnd.hour == 7 && schedule.intervalEnd.minute == 30)
        #expect(schedule.repeats)
        #expect(schedule.warningTime?.minute == 30)
    }

    @Test func aMarginBeforeMidnightBedtimeWrapsToTheEvening() {
        var sleep = SleepSettings()
        sleep.bedtime = 15
        sleep.margin = 30
        #expect(sleep.schedule.intervalStart.hour == 23 && sleep.schedule.intervalStart.minute == 45)
    }

    @Test func onlyTheChosenNights() throws {
        let calendar = Calendar(identifier: .gregorian)
        var sleep = SleepSettings()
        sleep.days = [2, 3, 4, 5, 6]
        let saturday = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 24, hour: 23)))
        let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 26, hour: 23)))
        #expect(!sleep.isNight(startingAt: saturday, calendar: calendar))
        #expect(sleep.isNight(startingAt: monday, calendar: calendar))
    }
}
