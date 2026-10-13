import Foundation

/// How a refresh changes the Abitudini condivise received, from the list of every share iCloud
/// has for this user.
///
/// - A share listed with a snapshot replaces the copy here, keeping the owner's emoji and the
///   place in the grid; a new one goes last.
/// - A share listed without a snapshot keeps the copy here, or waits if there is none.
/// - A share no longer listed is gone: the owner stopped sharing or deleted the habit.
/// - A share the user removed stays hidden; once iCloud no longer lists it, it is forgotten.
nonisolated enum ReceivedHabitsMerge {
    static func merge(_ file: ReceivedHabitsFile, with fetched: [FetchedShare]) -> ReceivedHabitsFile {
        let listed = Dictionary(fetched.map { ($0.key, $0.snapshot) }, uniquingKeysWith: { first, _ in first })
        var result = ReceivedHabitsFile()
        result.removed = file.removed.filter { listed[$0] != nil }
        for received in file.habits {
            guard let entry = listed[received.key], result.removed.contains(received.key) == false else { continue }
            var updated = received
            if let snapshot = entry {
                updated.snapshot = snapshot
            }
            result.habits.append(updated)
        }
        var known = Set(result.habits.map(\.key)).union(result.removed)
        for share in fetched where known.contains(share.key) == false {
            guard let snapshot = share.snapshot else { continue }
            result.habits.append(ReceivedHabit(key: share.key, snapshot: snapshot))
            known.insert(share.key)
        }
        return result
    }
}
