import Foundation

/// A JSON file in the app's own folder, on this iPhone only.
///
/// Application Support is backed up to iCloud by default, so every write marks the file as
/// excluded from backup: what Sbu Find keeps never leaves the iPhone.
struct LocalFile<Value: Codable> {
    let url: URL

    /// The value saved; `nil` when there is none or it cannot be read.
    func load() -> Value? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    func save(_ value: Value) {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(value).write(to: url, options: [.atomic, .completeFileProtection])
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
