import Foundation

/// Where a dose stands at a moment.
nonisolated enum DoseState: Hashable, Sendable {
    /// Due later.
    case upcoming
    /// Its time has passed today and it is not marked yet.
    case late
    case taken(at: Date)
    case skipped
    /// A past day ended without a mark.
    case missed

    /// Still to take: upcoming or late.
    var isToTake: Bool {
        self == .upcoming || self == .late
    }

    var isTaken: Bool {
        if case .taken = self { return true }
        return false
    }
}
