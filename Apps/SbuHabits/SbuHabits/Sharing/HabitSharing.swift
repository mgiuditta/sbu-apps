import CloudKit
import Foundation
import Observation

/// The owner's Abitudini condivise: which habits are shared and with how many people, and the
/// snapshot each one shows, sent again shortly after every save that changes it. Deleting a
/// shared habit stops sharing it. Independent from Sincronizza con iCloud: it needs iCloud, not
/// the switch.
@Observable
final class HabitSharing {
    /// iCloud is signed in: without it Condividi is off and says why.
    private(set) var isAvailable: Bool
    /// The habits shared now, with the people each one is shared with, the owner left out.
    private(set) var participants: [UUID: Int] = [:]

    @ObservationIgnored private let model: HabitsModel
    @ObservationIgnored private let outbox: (any SharedHabitsOutbox)?
    /// The last snapshot sent of each shared habit, so an unchanged one is not sent again.
    @ObservationIgnored private var published: [UUID: SharedHabitSnapshot] = [:]
    @ObservationIgnored private var pending: Task<Void, Never>?
    @ObservationIgnored private var isPublishing = false
    @ObservationIgnored private var needsAnotherPass = false

    /// - Parameters:
    ///   - outbox: CloudKit, a fake in tests; `nil` never shares, for UI tests and previews.
    ///   - isAvailable: Whether iCloud looks signed in while there is no outbox to ask.
    init(model: HabitsModel, outbox: (any SharedHabitsOutbox)?, isAvailable: Bool = false) {
        self.model = model
        self.outbox = outbox
        self.isAvailable = outbox == nil && isAvailable
        model.didSaveForSharing = { [weak self] in
            self?.schedulePublish(after: .seconds(2))
        }
    }

    /// How many people `habit` is shared with, `nil` when it is not shared.
    func participantCount(of habit: Habit) -> Int? {
        participants[habit.id]
    }

    /// At launch and whenever the app comes back: the account, the shares, and any change not sent.
    func appDidBecomeActive() async {
        guard let outbox else { return }
        isAvailable = await outbox.isAccountAvailable()
        guard isAvailable else { return }
        await refreshShares()
        await publishChanges()
    }

    /// When the app leaves: sends a change still waiting for its delay.
    func appDidEnterBackground() {
        guard pending != nil else { return }
        schedulePublish(after: .zero)
    }

    /// The share of `habit` for the system sharing screen, made now if it is not shared yet.
    func prepareShare(of habit: Habit) async throws -> CKShare {
        guard let outbox, isAvailable else { throw SharingFailure.unavailable }
        let snapshot = SharedHabitSnapshot(habit: habit, startHour: model.startHour)
        let share = try await outbox.prepareShare(of: habit.id, title: habit.title, snapshot: try snapshot.encoded())
        published[habit.id] = snapshot
        participants[habit.id] = participants[habit.id] ?? 0
        return share
    }

    /// After the system sharing screen: people invited or removed, or sharing stopped. Stopping
    /// deletes the zone too, so nothing of the habit stays in iCloud.
    func sharingDidChange(for habitID: UUID, stopped: Bool) async {
        guard let outbox else { return }
        if stopped {
            participants[habitID] = nil
            published[habitID] = nil
            try? await outbox.stopSharing(habitID)
        }
        await refreshShares()
    }

    /// Reads which habits are shared, and with how many people. A failed read keeps what is known.
    func refreshShares() async {
        guard let outbox, let shared = try? await outbox.sharedHabits() else { return }
        participants = shared
        published = published.filter { shared[$0.key] != nil }
    }

    /// Sends the snapshot of every shared habit that changed since it was last sent, and stops
    /// sharing the ones deleted. One pass at a time; a request during a pass runs one more after it.
    func publishChanges() async {
        guard let outbox, isAvailable, model.isUnreadable == false else { return }
        guard isPublishing == false else {
            needsAnotherPass = true
            return
        }
        isPublishing = true
        repeat {
            needsAnotherPass = false
            await pass(with: outbox)
        } while needsAnotherPass
        isPublishing = false
    }

    private func pass(with outbox: any SharedHabitsOutbox) async {
        for habitID in participants.keys.sorted(by: { $0.uuidString < $1.uuidString }) {
            guard let habit = model.habits.first(where: { $0.id == habitID }) else {
                // Only a habit deleted for good: one another iPhone has not synced here yet stays shared.
                if model.deleted[habitID] != nil {
                    participants[habitID] = nil
                    published[habitID] = nil
                    try? await outbox.stopSharing(habitID)
                }
                continue
            }
            let snapshot = SharedHabitSnapshot(habit: habit, startHour: model.startHour)
            guard published[habitID] != snapshot, let data = try? snapshot.encoded() else { continue }
            do {
                try await outbox.publish(data, of: habitID)
                published[habitID] = snapshot
            } catch SharingFailure.notShared {
                participants[habitID] = nil
                published[habitID] = nil
            } catch {
                // Offline or iCloud busy: the next save or the next time the app comes back sends it.
            }
        }
    }

    private func schedulePublish(after delay: Duration) {
        guard outbox != nil, participants.isEmpty == false else { return }
        pending?.cancel()
        pending = Task { [weak self] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard Task.isCancelled == false, let self else { return }
            pending = nil
            await publishChanges()
        }
    }
}
