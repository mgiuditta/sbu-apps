import Foundation

/// What a library item weighs on disk, measured once and cached by identifier.
nonisolated struct ItemSize: Codable, Hashable, Sendable {
    /// All the item's resources together: original, edits, the video of a Live Photo.
    var bytes: Int64
    /// The video part of a Live Photo; zero for anything else.
    var pairedVideoBytes: Int64 = 0
    /// The item's modification date when it was measured: a different one means measure again.
    var modified: Date?
}
