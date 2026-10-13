import Foundation
import Testing
@testable import SbuNoise

struct SoundAlarmTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        return calendar
    }()

    /// Monday 12 October 2026 at the given time, in Rome.
    private func monday(_ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: hour, minute: minute))!
    }

    @Test func aOneOffAlarmRingsAtTheNextMatchingTime() {
        let alarm = SoundAlarm(hour: 7, minute: 30).armed(at: monday(23))
        #expect(alarm.fireDate(after: monday(23), calendar: calendar) == monday(7, 30).addingTimeInterval(86_400))
        #expect(alarm.fireDate(after: monday(6), calendar: calendar) == monday(7, 30).addingTimeInterval(86_400), "Armed in the evening, it is for tomorrow")
    }

    @Test func aOneOffAlarmThatPassedHasExpired() {
        let alarm = SoundAlarm(hour: 7, minute: 30).armed(at: monday(6))
        #expect(alarm.fireDate(after: monday(7, 29), calendar: calendar) == monday(7, 30))
        #expect(alarm.fireDate(after: monday(8), calendar: calendar) == nil)
        #expect(alarm.hasExpired(at: monday(8)))
    }

    @Test func aRepeatingAlarmPicksTheNextOfItsDays() {
        // Wednesday (4) and Friday (6).
        let alarm = SoundAlarm(hour: 6, minute: 45, weekdays: [4, 6])
        let wednesday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: 6, minute: 45))!
        #expect(alarm.fireDate(after: monday(12), calendar: calendar) == wednesday)
        #expect(!alarm.hasExpired(at: monday(12)))
    }

    @Test func rimandaRingsAgainAfterTheSnoozeMinutes() {
        let alarm = SoundAlarm(hour: 7, snoozeMinutes: 9).armed(at: monday(0)).snoozed(at: monday(7))
        #expect(alarm.fireDate(after: monday(7, 1), calendar: calendar) == monday(7, 9))
    }

    @Test(arguments: [(Set<Int>(), false), (Set([2, 3]), true)])
    func fermaTurnsOffOnlyOneOffAlarms(weekdays: Set<Int>, staysOn: Bool) {
        let alarm = SoundAlarm(hour: 7, weekdays: weekdays).snoozed(at: monday(7)).stopped(at: monday(7, 1))
        #expect(alarm.isOn == staysOn)
        #expect(alarm.snoozedUntil == nil)
    }

    @Test func anAlarmThatIsOffNeverRings() {
        var alarm = SoundAlarm(hour: 7, weekdays: [2])
        alarm.isOn = false
        #expect(alarm.fireDate(after: monday(0), calendar: calendar) == nil)
    }

    @Test func savedAlarmsLoadBack() throws {
        let store = NoiseStore.temporary
        let file = NoiseFile(timers: [], mixes: [])
        var saved = file
        saved.alarms = [SoundAlarm(hour: 6, minute: 15, weekdays: [2, 4], soundID: "noise.pink", fadeIn: .fiveMinutes, snoozeMinutes: 10)]
        try store.save(saved)
        #expect(try store.load() == saved)
    }
}

struct AlarmWarningTests {
    private let alarm = Date(timeIntervalSince1970: 100_000)

    @Test func noWarningWhenAllowedAndNoTimerBefore() {
        #expect(AlarmWarning.list(permission: .allowed, kind: .notifications, alarmDate: alarm, timerStop: alarm.addingTimeInterval(60)).isEmpty)
    }

    @Test(arguments: [(AlarmBackupKind.notifications, AlarmWarning.notificationsDenied), (.systemAlarm, .systemAlarmsDenied)])
    func aDeniedBackupIsSaid(kind: AlarmBackupKind, expected: AlarmWarning) {
        #expect(AlarmWarning.list(permission: .denied, kind: kind, alarmDate: alarm, timerStop: nil) == [expected])
    }

    @Test func aTimerThatStopsTheSoundFirstIsSaid() {
        #expect(AlarmWarning.list(permission: .allowed, kind: .notifications, alarmDate: alarm, timerStop: alarm.addingTimeInterval(-3_600)) == [.soundStopsBefore(.notifications)])
    }
}
