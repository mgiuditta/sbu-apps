import Foundation
import Observation
import UIKit

/// The alarms, saved in the Noise file; the task that rings the next one inside the app; and the
/// backup that rings instead when the app is not alive at that time.
///
/// Two seconds before the time, if the app will be alive (a sound plays, or it is on screen), the
/// backup for that alarm is taken back; then the alarm rings, fading in. If the sound cannot
/// start, the backup is put back for a few seconds later.
@Observable
final class AlarmsModel {
    private(set) var alarms: [SoundAlarm]
    /// The alarm ringing now, shown full screen with Rimanda and Ferma.
    private(set) var ringing: SoundAlarm?
    private(set) var permission: AlarmBackupPermission

    @ObservationIgnored let backup: any AlarmBackup
    /// Told when an alarm starts ringing in the app, to show it on the lock screen.
    @ObservationIgnored var didStartRinging: ((SoundAlarm) -> Void)?
    /// Told when the ringing alarm is silenced, to take it off the lock screen.
    @ObservationIgnored var didStopRinging: ((SoundAlarm) -> Void)?
    @ObservationIgnored private let store: NoiseStore
    @ObservationIgnored private let player: PlayerModel
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let canRingItself: () -> Bool
    @ObservationIgnored private var waiting: Task<Void, Never>?
    /// The backup's work, one call after the other: each replaces what the last one scheduled.
    @ObservationIgnored private var backupWork: Task<Void, Never>?

    /// How long before the time the backup is taken back.
    static let handover: Duration = .seconds(2)
    /// An alarm whose task wakes later than this (the app was suspended) does not ring late.
    static let lateness: TimeInterval = 60

    /// - Parameter canRingItself: Whether the app will be alive at the alarm's time; by default,
    ///   while a sound plays or the app is on screen.
    init(
        store: NoiseStore = .shared,
        player: PlayerModel,
        backup: any AlarmBackup = AlarmsModel.makeBackup(),
        now: @escaping () -> Date = Date.init,
        canRingItself: (() -> Bool)? = nil
    ) {
        self.store = store
        self.player = player
        self.backup = backup
        self.now = now
        self.canRingItself = canRingItself ?? { player.isPlaying || UIApplication.shared.applicationState == .active }
        // ponytail: an unreadable file starts empty; a newer version is never overwritten by `save`.
        alarms = (try? store.load().alarms) ?? []
        permission = backup.permission
        player.ringingStopRequested = { [weak self] in self?.stop() }
        refresh()
    }

    /// A system alarm from iOS 26, notifications before.
    static func makeBackup() -> any AlarmBackup {
        // UI tests run without the system permission prompt.
        if ProcessInfo.processInfo.environment["SBU_NOISE_BACKUP"] == "silent" { return SilentBackup() }
        if #available(iOS 26, *) { return SystemAlarmBackup() }
        return NotificationBackup()
    }

    /// The alarm that rings next, with its time.
    var next: (alarm: SoundAlarm, date: Date)? {
        SoundAlarm.next(in: alarms, after: now())
    }

    // MARK: Editing

    /// Adds a new alarm or replaces the one with the same id, armed from now. The first alarm asks
    /// for the backup's permission.
    func save(_ alarm: SoundAlarm) {
        let alarm = alarm.armed(at: now())
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
        } else {
            alarms.append(alarm)
        }
        commit()
        if backup.permission == .notAsked {
            enqueue { [weak self] backup in
                await backup.requestPermission()
                self?.permission = backup.permission
                await backup.replace(with: self?.plans() ?? [])
            }
        }
    }

    func setOn(_ isOn: Bool, for id: SoundAlarm.ID) {
        guard let index = alarms.firstIndex(where: { $0.id == id }) else { return }
        var alarm = alarms[index].armed(at: now())
        alarm.isOn = isOn
        alarms[index] = alarm
        commit()
    }

    func delete(_ id: SoundAlarm.ID) {
        alarms.removeAll { $0.id == id }
        commit()
        enqueue { await $0.cancel(alarmID: id) }
    }

    // MARK: Ringing

    /// Rings `alarm` in the app now; the schedule calls it at the alarm's time.
    func ring(_ alarm: SoundAlarm) {
        let sound = player.alarmSound(withID: alarm.soundID) ?? Sound.alarmTones[0]
        if player.ring(sound, fadeIn: alarm.fadeIn.duration) {
            ringing = alarm
            enqueue { await $0.cancel(alarmID: alarm.id) }
            // After the cancel, which also clears the alarm's delivered notifications.
            enqueue { [weak self] _ in self?.didStartRinging?(alarm) }
        } else if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            // The app could not ring: the backup rings in a few seconds instead.
            alarms[index] = alarm.stopped(at: now())
            commit(extra: [AlarmPlan(alarmID: alarm.id, date: now().addingTimeInterval(5))])
        }
    }

    /// Rimanda: silence, and ring again after the alarm's snooze minutes.
    func snooze() {
        guard let ringing else { return }
        player.stopRinging()
        self.ringing = nil
        didStopRinging?(ringing)
        update(ringing.snoozed(at: now()))
    }

    /// Ferma: silence; a one-off alarm turns off. Takes back what the backup still has for it.
    func stop() {
        guard let ringing else { return }
        player.stopRinging()
        self.ringing = nil
        didStopRinging?(ringing)
        update(ringing.stopped(at: now()))
        enqueue { await $0.cancel(alarmID: ringing.id) }
    }

    /// A tap on a backup notification or its buttons, or on the ringing notification.
    func handleBackupResponse(alarmID: UUID, snooze wantsSnooze: Bool) {
        if ringing?.id == alarmID {
            if wantsSnooze { snooze() } else { stop() }
            return
        }
        guard let alarm = alarms.first(where: { $0.id == alarmID }) else { return }
        enqueue { await $0.cancel(alarmID: alarmID) }
        update(wantsSnooze ? alarm.snoozed(at: now()) : alarm.stopped(at: now()))
    }

    /// When the app comes back: turns off one-off alarms the backup already rang, reads the
    /// permission again and schedules everything anew.
    func refresh() {
        let date = now()
        var changed = false
        for index in alarms.indices where alarms[index].hasExpired(at: date) && ringing?.id != alarms[index].id {
            alarms[index] = alarms[index].stopped(at: date)
            changed = true
        }
        if changed { try? store.update { $0.alarms = alarms } }
        schedule()
        enqueue { [weak self] backup in
            await backup.refreshPermission()
            self?.permission = backup.permission
            await backup.replace(with: self?.plans() ?? [])
        }
    }

    // MARK: Scheduling

    /// What the backup should ring: the next time of every alarm that is on.
    func plans() -> [AlarmPlan] {
        let date = now()
        return alarms.compactMap { alarm in alarm.fireDate(after: date).map { AlarmPlan(alarmID: alarm.id, date: $0) } }
    }

    /// Waits for what is queued for the backup; for tests and the handover.
    func backupSettled() async {
        await backupWork?.value
    }

    private func update(_ alarm: SoundAlarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index] = alarm
        commit()
    }

    /// Saves, waits for the next alarm, and gives the backup the new plans (and `extra` ones).
    private func commit(extra: [AlarmPlan] = []) {
        try? store.update { $0.alarms = alarms }
        schedule()
        let plans = plans() + extra
        enqueue { await $0.replace(with: plans) }
    }

    /// Runs `work` on the backup after the work already queued.
    private func enqueue(_ work: @escaping (any AlarmBackup) async -> Void) {
        let previous = backupWork
        let backup = backup
        backupWork = Task {
            await previous?.value
            await work(backup)
        }
    }

    /// Waits for the next alarm, hands over from the backup and rings. The app is alive while a
    /// sound plays, so this runs with the screen locked too.
    private func schedule() {
        waiting?.cancel()
        guard ringing == nil, let (alarm, date) = next else { return }
        waiting = Task { [weak self] in
            try? await Task.sleep(for: .seconds(date.timeIntervalSinceNow) - Self.handover)
            guard !Task.isCancelled, let self else { return }
            // Woken late after a suspension: the backup has rung already.
            guard self.now().timeIntervalSince(date) < Self.lateness else { return self.refresh() }
            if self.canRingItself() {
                self.enqueue { await $0.cancel(alarmID: alarm.id) }
                await self.backupSettled()
            }
            try? await Task.sleep(for: .seconds(max(0, date.timeIntervalSinceNow)))
            guard !Task.isCancelled else { return }
            self.ring(alarm)
        }
    }
}
