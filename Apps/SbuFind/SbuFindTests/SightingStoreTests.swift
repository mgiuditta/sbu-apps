import Foundation
import Testing
@testable import SbuFind

struct SightingStoreTests {
    @Test func aMissingFileIsAnEmptyLog() {
        #expect(SightingStore.temporary().load().sightings.isEmpty)
    }

    @Test func savesAndLoadsTheLog() {
        let store = SightingStore.temporary()
        var log = SightingLog()
        log.record(.fixture())
        store.save(log)
        #expect(store.load() == log)
    }

    /// Application Support goes to iCloud backups by default: the places must not.
    @Test func theSavedFileIsExcludedFromBackup() throws {
        let store = SightingStore.temporary()
        var log = SightingLog()
        log.record(.fixture())
        store.save(log)
        store.save(log)
        let values = try store.url.resourceValues(forKeys: [.isExcludedFromBackupKey])
        #expect(values.isExcludedFromBackup == true)
    }

    @Test func aDamagedFileIsAnEmptyLog() throws {
        let store = SightingStore.temporary()
        try Data("not json".utf8).write(to: store.url)
        #expect(store.load().sightings.isEmpty)
    }

    @Test func theDefaultFileIsInApplicationSupport() {
        #expect(SightingStore.defaultURL.deletingLastPathComponent() == URL.applicationSupportDirectory)
        #expect(SightingStore.defaultURL.lastPathComponent == "sightings.json")
    }
}
