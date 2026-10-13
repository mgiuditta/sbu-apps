import UIKit

/// The photo library as the cleaner uses it, so models and tests work without PhotoKit.
///
/// `PhotoKitLibrary` is the real one; `DemoLibrary` draws its own pictures for previews, UI
/// tests and screenshots. Implementations do their slow work off the main actor.
nonisolated protocol PhotoLibrary: Sendable {
    /// The access the user gave, without asking.
    func currentAccess() -> LibraryAccess

    /// Asks for access the first time; afterwards returns the current one.
    func requestAccess() async -> LibraryAccess

    /// Every photo and video, newest first, without sizes.
    func fetchItems() async -> [MediaItem]

    /// Measures the size on disk of the given items.
    func measure(_ ids: [String]) async -> [String: ItemSize]

    /// The user's own albums.
    func albums() async -> [Album]

    /// The items of one album, newest first.
    func itemIDs(inAlbum albumID: String) async -> [String]

    /// A picture of the item fitting a square of `pixelSide` pixels; `nil` when unavailable.
    func image(for id: String, pixelSide: CGFloat) async -> UIImage?

    /// Feature print, face quality and sharpness of a photo, for duplicates and similar.
    func analyze(_ id: String) async -> ImageAnalysis?

    /// A file the video player can open; `nil` when the video is only in iCloud.
    func videoURL(for id: String) async -> URL?

    /// File name and camera, for the long press on a card.
    func details(for id: String) async -> MediaDetails

    /// Deletes the items from the library. The system asks the user first and throws
    /// `LibraryError.cancelled` if the user says no.
    func delete(_ ids: [String]) async throws

    /// Saves a still copy of a Live Photo, with its date, place and favourite, and returns
    /// the new item's identifier. The original stays.
    func saveStill(ofLivePhoto id: String) async throws -> String

    /// Saves a compressed copy of a video and returns the new item's identifier. The original stays.
    func saveCompressed(video id: String, quality: CompressionQuality) async throws -> String

    /// Yields whenever the library changes outside the app.
    func changes() -> AsyncStream<Void>
}
