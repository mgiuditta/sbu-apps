import Foundation

/// A JSON file in the app's own folder, on this iPhone only.
///
/// Application Support is backed up to iCloud by default, so every write marks the file as
/// excluded from backup: what Sbu Find keeps never leaves the iPhone.
///
/// The file stays encrypted until the first unlock after a restart, then readable also with the
/// iPhone locked: iOS relaunches the app in the background for a saved device, often in a pocket.
struct LocalFile<Value: Codable> {
    let url: URL

    /// The value saved, or why there is none.
    func read() -> FileContents<Value> {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return .empty
        } catch {
            return .unavailable
        }
        guard let value = try? JSONDecoder().decode(Value.self, from: data) else { return .empty }
        return .loaded(value)
    }

    func save(_ value: Value) {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(value).write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
            // An atomic write replaces the file, and with it its resource values: mark it again.
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            var file = url
            try file.setResourceValues(values)
        } catch {
            // Not saved: the next change tries again. Nothing to tell the person.
        }
    }
}
