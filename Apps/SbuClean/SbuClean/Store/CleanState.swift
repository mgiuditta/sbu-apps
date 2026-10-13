import Foundation

/// Everything the user decided, by PhotoKit identifier, saved on the device.
///
/// Identifiers are stable across app updates, so progress month by month and the bin survive
/// an update, which is what the Originali lose.
nonisolated struct CleanState: Codable, Equatable, Sendable {
    /// Swiped right.
    var kept: Set<String> = []
    /// In the bin, in the order they were marked.
    var trash: [String] = []
    /// Set aside to decide later.
    var later: Set<String> = []
    /// Never proposed again.
    var keepForever: Set<String> = []
    var freed = FreedSpace()

    /// The decision about an item; `nil` when it is still to see.
    func decision(for id: String) -> SwipeDecision? {
        if keepForever.contains(id) { return .keepForever }
        if trash.contains(id) { return .trash }
        if later.contains(id) { return .later }
        if kept.contains(id) { return .keep }
        return nil
    }

    /// Replaces the decision about an item; `nil` makes it to see again.
    mutating func set(_ decision: SwipeDecision?, for id: String) {
        kept.remove(id)
        later.remove(id)
        keepForever.remove(id)
        trash.removeAll { $0 == id }

        switch decision {
        case .keep: kept.insert(id)
        case .trash: trash.append(id)
        case .later: later.insert(id)
        case .keepForever: keepForever.insert(id)
        case nil: break
        }
    }

    /// Puts items in the bin, after the ones already there, skipping those kept forever.
    mutating func addToTrash(_ ids: some Sequence<String>) {
        var present = Set(trash)
        for id in ids where !present.contains(id) && !keepForever.contains(id) {
            kept.remove(id)
            later.remove(id)
            trash.append(id)
            present.insert(id)
        }
    }

    /// Forgets items that are no longer in the library.
    mutating func forget(_ ids: Set<String>) {
        guard !ids.isEmpty else { return }

        kept.subtract(ids)
        later.subtract(ids)
        keepForever.subtract(ids)
        trash.removeAll { ids.contains($0) }
    }

    /// Keeps only the decisions about items still in the library.
    mutating func keepOnly(_ existing: Set<String>) {
        kept.formIntersection(existing)
        later.formIntersection(existing)
        keepForever.formIntersection(existing)
        trash.removeAll { !existing.contains($0) }
    }
}
