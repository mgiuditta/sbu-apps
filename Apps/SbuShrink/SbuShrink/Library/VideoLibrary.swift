import Foundation

/// The photo library, as far as Shrink needs it: save the copies, delete the originals.
nonisolated protocol VideoLibrary: Sendable {
    /// The current permission, without asking.
    func access() -> LibraryAccess
    /// Asks for read and write access when it was never asked, and returns the result.
    func requestAccess() async -> LibraryAccess
    /// Saves the video at `url` to Photos, with the date and place of `original` when there is
    /// one, and adds it to the "Video compressi" album when `toAlbum`.
    /// - Returns: The new asset's identifier.
    func save(_ url: URL, original: String?, toAlbum: Bool) async throws -> String
    /// Deletes these assets; iOS asks the user once more and moves them to Recently Deleted.
    /// - Returns: How many were deleted, which can be fewer than asked when some are gone or
    ///   not shared with the app.
    func delete(_ ids: [String]) async throws -> Int
}
