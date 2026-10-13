import Foundation

/// What reading the copy on iCloud found.
nonisolated enum RemoteRead: Sendable, Equatable {
    /// No copy yet: the first iPhone to sync writes it.
    case missing
    /// A copy is on iCloud but not on this iPhone yet; its download has started.
    case downloading
    /// The copy, and the versions iCloud kept when two iPhones wrote at once, to merge too.
    case found(Data, conflicts: [RemoteConflict])
}
