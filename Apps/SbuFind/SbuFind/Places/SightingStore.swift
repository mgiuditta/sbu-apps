import Foundation

/// Keeps the sighting log in a local file, excluded from backup: the places never leave the iPhone.
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
        LocalFile<SightingLog>(url: url).load() ?? SightingLog()
    }

    func save(_ log: SightingLog) {
        LocalFile(url: url).save(log)
    }
}
