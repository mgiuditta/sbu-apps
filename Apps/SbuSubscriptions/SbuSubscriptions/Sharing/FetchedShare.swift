import Foundation

/// One shared list as a refresh found it in iCloud.
nonisolated struct FetchedShare: Equatable, Sendable {
    let key: String
    /// `nil` when its record could not be read this time, or comes from a newer app: the copy here stays.
    let snapshot: SharedListSnapshot?
}
