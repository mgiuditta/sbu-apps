import Foundation
import Testing
@testable import SbuNoise

struct SoundTimerTests {
    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        calendar.locale = Locale(identifier: "it_IT")
        return calendar
    }

    /// Monday 13 October 2025, 22:00 in Rome.
    private static let monday = calendar.date(from: DateComponents(year: 2025, month: 10, day: 13, hour: 22))!

    private func at(day: Int, hour: Int, minute: Int = 0) -> Date {
        Self.calendar.date(from: DateComponents(year: 2025, month: 10, day: day, hour: hour, minute: minute))!
    }

    @Test func aDurationFiresThatLongAfterItStarted() {
        let timer = SoundTimer(trigger: .duration(minutes: 90), startedAt: Self.monday)
        #expect(timer.fireDate(after: Self.monday, calendar: Self.calendar) == at(day: 13, hour: 23, minute: 30))
    }

    @Test func aDurationNotArmedOrOffNeverFires() {
        #expect(SoundTimer(trigger: .duration(minutes: 30)).fireDate(after: Self.monday) == nil)
        #expect(SoundTimer(isOn: false, startedAt: Self.monday).fireDate(after: Self.monday) == nil)
    }

    @Test(arguments: [
        (23, 30, 13), // later today
        (7, 0, 14),   // past today: tomorrow
    ])
    func aOneOffClockFiresAtTheNextOccurrence(hour: Int, minute: Int, day: Int) {
        let timer = SoundTimer(trigger: .clock(hour: hour, minute: minute))
        #expect(timer.fireDate(after: Self.monday, calendar: Self.calendar) == at(day: day, hour: hour, minute: minute))
    }

    @Test func aClockOnWeekdaysFiresOnTheNextChosenDay() {
        // Wednesday (4) and Saturday (7) at 21:00: Monday 22:00 is past, so Wednesday 15.
        let timer = SoundTimer(trigger: .clock(hour: 21, minute: 0), weekdays: [7, 4])
        #expect(timer.fireDate(after: Self.monday, calendar: Self.calendar) == at(day: 15, hour: 21))
    }

    @Test(arguments: [
        (SoundTimerFade.none, 0.0),
        (.thirtySeconds, 30),
        (.fiveMinutes, 300),
    ])
    func theFadeEndsWhenTheTimerFires(fade: SoundTimerFade, secondsBefore: Double) {
        let fire = Self.monday.addingTimeInterval(3_600)
        let start = SoundTimer(fade: fade).fadeStart(firingAt: fire, now: Self.monday)
        #expect(start == fire.addingTimeInterval(-secondsBefore))
    }

    @Test func theFadeNeverStartsInThePast() {
        let fire = Self.monday.addingTimeInterval(10)
        #expect(SoundTimer(fade: .oneMinute).fadeStart(firingAt: fire, now: Self.monday) == Self.monday)
    }

    @Test(arguments: [
        (SoundTimerTrigger.duration(minutes: 30), false, [Int](), false),
        (.duration(minutes: 30), true, [], true),
        (.clock(hour: 23, minute: 0), false, [], false),
        (.clock(hour: 23, minute: 0), false, [2], true),
    ])
    func afterFiringOnlyRepeatingTimersStayOn(trigger: SoundTimerTrigger, repeatsAlways: Bool, weekdays: [Int], staysOn: Bool) {
        let timer = SoundTimer(trigger: trigger, repeatsAlways: repeatsAlways, weekdays: Set(weekdays), startedAt: Self.monday).fired()
        #expect(timer.isOn == staysOn)
        #expect(timer.startedAt == nil)
    }

    @Test func turningADurationOnStartsItsCountdown() {
        let timer = SoundTimer(isOn: false).turned(on: true, at: Self.monday)
        #expect(timer.startedAt == Self.monday)
        #expect(timer.turned(on: false, at: Self.monday).startedAt == nil)
    }

    @Test func theNextTimerIsTheEarliest() {
        let late = SoundTimer(trigger: .clock(hour: 23, minute: 30))
        let soon = SoundTimer(trigger: .duration(minutes: 10), startedAt: Self.monday)
        let off = SoundTimer(isOn: false, trigger: .clock(hour: 22, minute: 1))
        let next = SoundTimer.next(in: [late, soon, off], after: Self.monday, calendar: Self.calendar)
        #expect(next?.timer == soon)
    }

    @Test func weekdaysFollowTheLocaleWeek() {
        #expect(SoundTimer.orderedWeekdays(Self.calendar) == [2, 3, 4, 5, 6, 7, 1])
    }
}
