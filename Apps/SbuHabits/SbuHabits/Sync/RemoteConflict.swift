import Foundation

/// A version of the copy on iCloud that lost a write race with another iPhone: merged, then
/// marked resolved, so no iPhone's change is dropped.
nonisolated struct RemoteConflict: Sendable, Equatable {
    /// Where iCloud keeps this version, to mark it resolved after the merge is written.
    let url: URL
    let data: Data
}
