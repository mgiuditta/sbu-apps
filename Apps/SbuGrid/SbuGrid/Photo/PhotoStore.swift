import CoreGraphics
import Foundation

/// Keeps the photo being drawn between launches, as a JPEG in Application Support. Nothing else
/// is kept: there are no projects, and the photo never leaves the iPhone.
nonisolated struct PhotoStore: Sendable {
    let directory: URL

    init(directory: URL) {
        self.directory = directory
    }

    /// The store of the app, in Application Support: the photo is the user's work, so it goes
    /// into the iPhone's own backup like any other app data.
    static var standard: PhotoStore {
        PhotoStore(directory: URL.applicationSupportDirectory.appending(path: "Grid", directoryHint: .isDirectory))
    }

    var photoURL: URL {
        directory.appending(path: "photo.jpg")
    }

    /// Replaces the kept photo.
    func save(_ image: CGImage) throws {
        guard let data = PhotoDecoder.jpegData(from: image) else { throw PhotoError.unreadable }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: photoURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }

    /// The kept photo, or `nil` when there is none or it no longer reads.
    func load() -> CGImage? {
        guard let data = try? Data(contentsOf: photoURL) else { return nil }
        return try? PhotoDecoder.image(from: data)
    }

    func remove() {
        try? FileManager.default.removeItem(at: photoURL)
    }
}
