import Foundation

/// Keeps the sighting log in a file in the app's own folder, on this iPhone only.
///
/// Application Support is backed up to iCloud by default, so every write marks the file as
/// excluded from backup: the places never leave the iPhone.
struct SightingStore {
    /// The file in Application Support.
    static var defaultURL: URL {
        URL.applicationSupportDirectory.appending(path: "sightings.json")
    }

    let url: URL

    init(url: URL = SightingStore.defaultURL) {
        self.url = url
    }

    /// The saved log; empty when there is none or it cannot be read.
    func load() -> SightingLog {
        guard let data = try? Data(contentsOf: url) else { return SightingLog() }
        return (try? JSONDecoder().decode(SightingLog.self, from: data)) ?? SightingLog()
    }

    func save(_ log: SightingLog) {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(log).write(to: url, options: [.atomic, .completeFileProtection])
            // An atomic write replaces the file, and with it its resource values: mark it again.
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            var file = url
            try file.setResourceValues(values)
        } catch {
            // Not saved: the next sighting tries again. Nothing to tell the person.
        }
    }
}
