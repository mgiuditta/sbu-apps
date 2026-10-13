import CloudKit
import Foundation
import Observation

/// The Abitudini condivise other people share with this user: read only, kept in a file of their
/// own, refreshed from iCloud when the app comes back and when iCloud says one changed. They are
/// never marked, never in the Serie piena, the widgets or the reminders, and never count toward
/// the limit of the user's own habits.
@Observable
final class ReceivedHabits {
    private(set) var habits: [ReceivedHabit] = []

    @ObservationIgnored private let store: ReceivedHabitsStore
    @ObservationIgnored private let inbox: (any SharedHabitsInbox)?
    @ObservationIgnored private let preferences: UserDefaults?
    /// The file could not be read: nothing is written, so it is never lost.
    @ObservationIgnored private var isUnreadable = false

    private static let subscribedKey = "subscribedToSharedHabits"

    /// - Parameters:
    ///   - inbox: CloudKit, a fake in tests; `nil` never reaches iCloud, for UI tests and previews.
    ///   - preferences: Where the subscription is remembered; `nil` subscribes at every launch.
    init(store: ReceivedHabitsStore, inbox: (any SharedHabitsInbox)?, preferences: UserDefaults? = nil) {
        self.store = store
        self.inbox = inbox
        self.preferences = preferences
        reload()
    }

    func reload() {
        do {
            habits = try store.load().habits
            isUnreadable = false
        } catch {
            habits = []
            isUnreadable = true
        }
    }

    /// Joins a share opened from an invitation, then shows it.
    func accept(_ metadata: CKShare.Metadata) async {
        // The owner opening their own link: it is already theirs.
        guard let inbox, metadata.participantRole != .owner else { return }
        try? await inbox.accept(metadata)
        await refresh()
    }

    /// Reads every share from iCloud and takes the changes; leaves again the shares the user
    /// removed. Nothing changes when iCloud cannot be reached.
    func refresh() async {
        guard let inbox, isUnreadable == false else { return }
        await subscribeIfNeeded(with: inbox)
        for key in (try? store.load().removed) ?? [] {
            try? await inbox.leave(key)
        }
        guard let fetched = try? await inbox.fetchAll() else { return }
        // Read again after the wait: an emoji picked meanwhile stays.
        guard let file = try? store.load() else { return }
        save(ReceivedHabitsMerge.merge(file, with: fetched))
    }

    /// The icon for the owner of `received`, on this iPhone only; `nil` for the person symbol.
    func setOwnerEmoji(_ emoji: String?, for received: ReceivedHabit) {
        guard var file = try? store.load(), let index = file.habits.firstIndex(where: { $0.key == received.key }) else { return }
        file.habits[index].ownerEmoji = OwnerEmoji.validated(emoji)
        save(file)
    }

    /// Takes the habit off this iPhone and leaves its share; until iCloud confirms, it stays hidden.
    func remove(_ received: ReceivedHabit) async {
        guard var file = try? store.load() else { return }
        file.habits.removeAll { $0.key == received.key }
        file.removed.insert(received.key)
        save(file)
        guard let inbox else { return }
        do {
            try await inbox.leave(received.key)
            guard var file = try? store.load() else { return }
            file.removed.remove(received.key)
            save(file)
        } catch {
            // Left again at the next refresh.
        }
    }

    private func save(_ file: ReceivedHabitsFile) {
        guard isUnreadable == false else { return }
        // ponytail: a failed write keeps the change in memory only; the next refresh writes again.
        try? store.save(file)
        habits = file.habits
    }

    private func subscribeIfNeeded(with inbox: any SharedHabitsInbox) async {
        guard preferences?.bool(forKey: Self.subscribedKey) != true else { return }
        do {
            try await inbox.subscribe()
            preferences?.set(true, forKey: Self.subscribedKey)
        } catch {
            // Tried again at the next refresh.
        }
    }
}
