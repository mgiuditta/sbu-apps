import Foundation

/// Keeps the sighting log in a file in the app's own folder: never in iCloud, never sent.
struct SightingStore {
    /// The file in Application Support, excluded from backups like everything there is not.
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
        } catch {
            // Not saved: the next sighting tries again. Nothing to tell the person.
        }
    }
}
