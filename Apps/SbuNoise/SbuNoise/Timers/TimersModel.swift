import Foundation
import Observation

/// The timers, saved in the Noise file, and the one task that waits for the next of them to fade
/// the sound out and stop it.
@Observable
final class TimersModel {
    private(set) var timers: [SoundTimer]

    @ObservationIgnored private let store: NoiseStore
    @ObservationIgnored private let player: PlayerModel
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var waiting: Task<Void, Never>?

    init(store: NoiseStore = .shared, player: PlayerModel, now: @escaping () -> Date = Date.init) {
        self.store = store
        self.player = player
        self.now = now
        // ponytail: an unreadable file starts empty; a newer version is never overwritten by `save`.
        timers = (try? store.load().timers) ?? []
        followPlayback()
        schedule()
    }

    /// The timer that stops the sound next, with the moment it is silent.
    var next: (timer: SoundTimer, date: Date)? {
        SoundTimer.next(in: timers, after: now())
    }

    /// Adds a new timer or replaces the one with the same id; a duration starts counting now.
    func save(_ timer: SoundTimer) {
        let timer = timer.turned(on: timer.isOn, at: now())
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index] = timer
        } else {
            timers.append(timer)
        }
        commit()
    }

    func setOn(_ isOn: Bool, for id: SoundTimer.ID) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        timers[index] = timers[index].turned(on: isOn, at: now())
        commit()
    }

    func delete(at offsets: IndexSet) {
        timers.remove(atOffsets: offsets)
        commit()
    }

    func delete(_ id: SoundTimer.ID) {
        timers.removeAll { $0.id == id }
        commit()
    }

    /// A sound started: repeating duration timers that already fired count again from now.
    func playbackStarted() {
        var changed = false
        for index in timers.indices where timers[index].isOn && timers[index].startedAt == nil {
            guard case .duration = timers[index].trigger else { continue }
            timers[index].startedAt = now()
            changed = true
        }
        if changed { commit() }
    }

    /// Marks a timer as fired: one-off timers turn off.
    func fired(_ id: SoundTimer.ID) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        timers[index] = timers[index].fired()
        commit()
    }

    private func commit() {
        try? store.update { $0.timers = timers }
        schedule()
    }

    /// Waits for the next timer, then fades out and stops. The app stays alive while a sound plays,
    /// so this runs with the screen locked too.
    private func schedule() {
        waiting?.cancel()
        guard let (timer, date) = next else { return }
        let fadeStart = timer.fadeStart(firingAt: date, now: now())
        waiting = Task { [weak self, player] in
            try? await Task.sleep(for: .seconds(fadeStart.timeIntervalSince(Date.now)))
            guard !Task.isCancelled else { return }
            await player.fadeOut(over: .seconds(max(0, date.timeIntervalSince(Date.now))))
            guard !Task.isCancelled else { return }
            self?.fired(timer.id)
        }
    }

    private func followPlayback() {
        withObservationTracking {
            _ = player.isPlaying
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                if self.player.isPlaying { self.playbackStarted() }
                self.followPlayback()
            }
        }
    }
}
