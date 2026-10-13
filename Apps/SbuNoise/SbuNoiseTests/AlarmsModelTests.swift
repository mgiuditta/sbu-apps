import Foundation
import Testing
@testable import SbuNoise

/// The alarm's flows through the model, with a backup that only records what it is asked.
struct AlarmsModelTests {
    private let store = NoiseStore.temporary
    private let backup = SilentBackup()
    private let player = PlayerModel(sounds: Sound.generated, library: Library(store: .temporary), defaults: UserDefaults(suiteName: UUID().uuidString)!)

    private func model() -> AlarmsModel {
        AlarmsModel(store: store, player: player, backup: backup, canRingItself: { true })
    }

    @Test func savingAnAlarmGivesTheBackupItsTime() async throws {
        let alarms = model()
        let alarm = SoundAlarm(hour: 7, weekdays: [1, 2, 3, 4, 5, 6, 7])
        alarms.save(alarm)
        await alarms.backupSettled()

        let date = try #require(alarms.next?.date)
        #expect(backup.plans == [AlarmPlan(alarmID: alarm.id, date: date)])
        #expect(try store.load().alarms.map(\.id) == [alarm.id])
    }

    @Test func ringingPlaysTheAlarmAndTakesTheBackupBack() async throws {
        let alarms = model()
        let alarm = SoundAlarm(hour: 7, soundID: "noise.brown", fadeIn: .thirtySeconds)
        alarms.save(alarm)
        player.togglePlayback()

        alarms.ring(try #require(alarms.alarms.first))
        await alarms.backupSettled()
        #expect(player.isRinging)
        #expect(!player.isPlaying, "The sound for sleeping gives way to the alarm")
        #expect(alarms.ringing?.id == alarm.id)
        #expect(backup.cancelled.contains(alarm.id))
    }

    @Test func fermaSilencesAndTurnsAOneOffAlarmOff() async throws {
        let alarms = model()
        alarms.save(SoundAlarm(hour: 7))
        alarms.ring(try #require(alarms.alarms.first))

        alarms.stop()
        await alarms.backupSettled()
        #expect(!player.isRinging)
        #expect(alarms.ringing == nil)
        #expect(alarms.alarms.first?.isOn == false)
        #expect(backup.plans.isEmpty)
    }

    @Test func rimandaRingsAgainLater() async throws {
        let alarms = model()
        alarms.save(SoundAlarm(hour: 7, snoozeMinutes: 5))
        alarms.ring(try #require(alarms.alarms.first))

        alarms.snooze()
        await alarms.backupSettled()
        #expect(!player.isRinging)
        let next = try #require(alarms.next?.date)
        #expect(abs(next.timeIntervalSinceNow - 300) < 5)
        #expect(backup.plans.map(\.date) == [next], "The backup also has the snooze")
    }

    @Test func pauseOnTheLockScreenStopsTheAlarm() throws {
        let alarms = model()
        alarms.save(SoundAlarm(hour: 7))
        alarms.ring(try #require(alarms.alarms.first))

        player.handle(.pause)
        #expect(alarms.ringing == nil)
        #expect(!player.isRinging)
    }

    @Test func aTapOnTheBackupNotificationStopsTheAlarm() async throws {
        let alarms = model()
        let alarm = SoundAlarm(hour: 7)
        alarms.save(alarm)

        alarms.handleBackupResponse(alarmID: alarm.id, snooze: false)
        await alarms.backupSettled()
        #expect(alarms.alarms.first?.isOn == false)
        #expect(backup.cancelled.contains(alarm.id))
    }

    @Test func aTimerFadeDoesNotSilenceTheAlarm() async throws {
        let alarms = model()
        alarms.save(SoundAlarm(hour: 7))
        alarms.ring(try #require(alarms.alarms.first))
        await player.fadeOut(over: .milliseconds(10))
        #expect(player.isRinging)
        alarms.stop()
    }

    @Test func deletingAnAlarmTakesItsBackupBack() async {
        let alarms = model()
        let alarm = SoundAlarm(hour: 7)
        alarms.save(alarm)
        alarms.delete(alarm.id)
        await alarms.backupSettled()
        #expect(alarms.alarms.isEmpty)
        #expect(backup.plans.isEmpty)
    }
}
