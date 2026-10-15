import Foundation

/// The synthetic exports in `Fixtures/`, written by `scripts/make_fixtures.py`.
enum Fixture {
    private final class BundleToken {}

    static func url(_ name: String) -> URL {
        let bundle = Bundle(for: BundleToken.self)
        let base = (name as NSString).deletingPathExtension
        let fileExtension = (name as NSString).pathExtension
        guard let url = bundle.url(forResource: base, withExtension: fileExtension) else {
            fatalError("Missing fixture \(name)")
        }
        return url
    }

    /// A copy of the fixture in a fresh temporary folder, safe to change or delete.
    static func copy(_ name: String, as newName: String? = nil) throws -> URL {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let destination = folder.appending(path: newName ?? name)
        try FileManager.default.copyItem(at: url(name), to: destination)
        return destination
    }

    /// Writes `text` to a temporary `.txt` file.
    static func textFile(_ text: String, name: String = "chat.txt") throws -> URL {
        let folder = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appending(path: name)
        try Data(text.utf8).write(to: url)
        return url
    }
}
