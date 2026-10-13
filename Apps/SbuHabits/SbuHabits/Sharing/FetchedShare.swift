import Foundation

/// One Abitudine condivisa as a refresh found it in iCloud.
nonisolated struct FetchedShare: Equatable, Sendable {
    let key: String
    /// `nil` when its record could not be read this time, or comes from a newer Sbu Habits: the
    /// copy already here stays as it is.
    let snapshot: SharedHabitSnapshot?
}
