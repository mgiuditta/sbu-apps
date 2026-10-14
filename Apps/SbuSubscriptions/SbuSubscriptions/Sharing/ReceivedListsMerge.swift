import Foundation

/// How a refresh changes the lists received, from every share iCloud has for this user:
/// a listed share with a snapshot replaces the copy here (keeping the owner's name); without one,
/// the copy stays; a share no longer listed is gone; a share the user removed stays hidden until
/// iCloud stops listing it.
nonisolated enum ReceivedListsMerge {
    static func merge(_ file: ReceivedListsFile, with fetched: [FetchedShare]) -> ReceivedListsFile {
        let listed = Dictionary(fetched.map { ($0.key, $0.snapshot) }, uniquingKeysWith: { first, _ in first })
        var result = ReceivedListsFile()
        result.removed = file.removed.filter { listed[$0] != nil }
        for received in file.lists {
            guard let entry = listed[received.key], !result.removed.contains(received.key) else { continue }
            var updated = received
            if let snapshot = entry { updated.snapshot = snapshot }
            result.lists.append(updated)
        }
        var known = Set(result.lists.map(\.key)).union(result.removed)
        for share in fetched where !known.contains(share.key) {
            guard let snapshot = share.snapshot else { continue }
            result.lists.append(ReceivedList(key: share.key, snapshot: snapshot))
            known.insert(share.key)
        }
        return result
    }
}
