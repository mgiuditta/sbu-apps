import Foundation
import Testing
@testable import SbuMeds

struct ScheduleTests {
    private let calendar = Fixtures.calendar
    private let today = Fixtures.today

    @Test func dailyIsDueEveryDayFromTheStart() {
        let schedule = Schedule(start: today)
        #expect(!schedule.isDue(on: Fixtures.day(-1), calendar: calendar))
        #expect((0..<10).allSatisfy { schedule.isDue(on: Fixtures.day($0), calendar: calendar) })
    }

    @Test func theEndDayIsIncludedAndNothingAfter() {
        let schedule = Schedule(start: today, end: Fixtures.day(4))
        #expect(schedule.isDue(on: Fixtures.day(4), calendar: calendar))
        #expect(!schedule.isDue(on: Fixtures.day(5), calendar: calendar))
        #expect(!schedule.isActive(on: Fixtures.day(5)))
    }

    /// 16 October 2026 is a Friday (weekday 6).
    @Test(arguments: [
        (0, true), (1, false), (2, false), (3, true), (5, true), (7, true),
    ])
    func weekdaysOnlyOnTheChosenDays(offset: Int, due: Bool) {
        let schedule = Schedule(frequency: .weekdays, weekdays: [2, 4, 6], start: today)
        #expect(schedule.isDue(on: Fixtures.day(offset), calendar: calendar) == due)
    }

    @Test(arguments: [(2, [0, 2, 4, 6, 8, 10, 12, 14]), (3, [0, 3, 6, 9, 12]), (7, [0, 7, 14])])
    func everyNDaysCountsFromTheStart(interval: Int, dueOffsets: [Int]) {
        let schedule = Schedule(frequency: .everyDays, interval: interval, start: today)
        let due = (0..<15).filter { schedule.isDue(on: Fixtures.day($0), calendar: calendar) }
        #expect(due == dueOffsets)
    }

    @Test func cycleIsOnThenOff() throws {
        let schedule = Schedule(frequency: .cycle, cycleOn: 3, cycleOff: 2, start: today)
        let due = (0..<12).map { schedule.isDue(on: Fixtures.day($0), calendar: calendar) }
        #expect(due == [true, true, true, false, false, true, true, true, false, false, true, true])
        let pause = try #require(schedule.cyclePhase(on: Fixtures.day(4), calendar: calendar))
        #expect(!pause.isOn && pause.dayOfPhase == 2)
        let again = try #require(schedule.cyclePhase(on: Fixtures.day(5), calendar: calendar))
        #expect(again.isOn && again.dayOfPhase == 1)
    }

    @Test func aTwentyOneSevenPackStartsAgainOnDayTwentyEight() {
        let schedule = Schedule(frequency: .cycle, cycleOn: 21, cycleOff: 7, start: today)
        #expect(schedule.isDue(on: Fixtures.day(20), calendar: calendar))
        #expect(!schedule.isDue(on: Fixtures.day(21), calendar: calendar))
        #expect(!schedule.isDue(on: Fixtures.day(27), calendar: calendar))
        #expect(schedule.isDue(on: Fixtures.day(28), calendar: calendar))
    }

    @Test(arguments: [
        (8, 8, [8, 16]),
        (6, 8, [6, 14, 22]),
        (0, 6, [0, 6, 12, 18]),
        (9, 12, [9, 21]),
        (22, 4, [22]),
    ])
    func everyNHoursStartsAgainEachDay(first: Int, hours: Int, expected: [Int]) {
        let schedule = Schedule(frequency: .everyHours, times: [DoseTime(hour: first)], interval: hours, start: today)
        #expect(schedule.times(on: Fixtures.day(1), calendar: calendar).map(\.hour) == expected)
    }

    @Test func asNeededIsNeverDue() {
        let schedule = Schedule(frequency: .asNeeded, start: today)
        #expect(schedule.times(on: today, calendar: calendar).isEmpty)
        #expect(!schedule.isActive(on: today))
    }

    @Test func timesAreSortedAndNeverTwiceAtTheSameMinute() {
        let schedule = Schedule(times: [DoseTime(hour: 20, amount: 2), DoseTime(hour: 8, amount: 1), DoseTime(hour: 20, amount: 3)], start: today)
        #expect(schedule.times.map(\.hour) == [8, 20])
        // The morning dose keeps its amount and the evening its own: never swapped.
        #expect(schedule.times.map(\.amount) == [1, 2])
    }

    @Test func outOfRangeValuesAreClamped() {
        let schedule = Schedule(frequency: .everyDays, weekdays: [0, 8, 3], interval: 500, cycleOn: 0, cycleOff: 1_000, start: today)
        #expect(schedule.weekdays == [3])
        #expect(schedule.interval == Schedule.maxInterval)
        #expect(schedule.cycleOn == 1)
        #expect(schedule.cycleOff == Schedule.maxCycleDays)
        #expect(DoseTime(minutes: 5_000).minutes == DoseTime.minutesInDay - 1)
    }

    /// The same schedule seen from Rome and from New York: 8:00 stays 8:00 local, on the same days.
    @Test func changingTimeZoneNeverMovesTheLocalTime() {
        let schedule = Schedule(times: [DoseTime(hour: 8), DoseTime(hour: 21)], start: today)
        for zone in ["Europe/Rome", "America/New_York", "Asia/Tokyo"] {
            let zoned = Fixtures.calendar(in: zone)
            let dates = schedule.times(on: today, calendar: zoned).map { DoseKey(medicineID: UUID(), day: today, minutes: $0.minutes).date(in: zoned) }
            #expect(dates.map { zoned.component(.hour, from: $0) } == [8, 21])
            #expect(dates.allSatisfy { Day($0, calendar: zoned) == today })
        }
    }

    /// The night daylight saving time ends in Europe (25 October 2026) has 25 hours: doses keep their clock time.
    @Test func daylightSavingTimeKeepsClockTimes() {
        let night = Day(year: 2026, month: 10, day: 25)
        let date = night.date(atMinutes: 8 * 60, in: calendar)
        #expect(calendar.component(.hour, from: date) == 8)
        #expect(night.adding(days: 1, in: calendar) == Day(year: 2026, month: 10, day: 26))
        #expect(Fixtures.today.days(to: night, in: calendar) == 9)
    }

    @Test(arguments: [20261016, 20260101, 20271231])
    func dayKeysRoundTrip(key: Int) {
        #expect(Day(key: key).key == key)
    }

    @Test func doseKeysRoundTripThroughNotifications() throws {
        let key = DoseKey(medicineID: UUID(), day: today, minutes: 495)
        #expect(DoseKey(string: key.string) == key)
        #expect(DoseKey(string: "nonsense") == nil)
    }
}
