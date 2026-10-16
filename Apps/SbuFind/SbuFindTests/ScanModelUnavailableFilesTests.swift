import Foundation
import Testing
@testable import SbuFind

/// Launched in the background before the first unlock, the saved files cannot be read: the model
/// must not take them as empty, nor save over them, and reads them again once it can.
struct ScanModelUnavailableFilesTests {
    let defaults: UserDefaults
    let scanner = FakeScanner()
    let store = SightingStore.temporary()
    let mineStore = MyDevicesStore(url: URL.temporaryDirectory.appending(path: "mine-\(UUID().uuidString).json"))
    let saved = [SavedDevice(name: "Il mio orologio", device: NearbyDevice(
        id: Advertisement.testID(1), name: "Forerunner", kind: .watch, signal: -60,
        lastSeen: Advertisement.start, serviceUUIDs: ["180D"]
    ))]

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "ScanModelUnavailableFilesTests-\(UUID().uuidString)"))
    }

    private func makeModel() -> ScanModel {
        ScanModel(scanner: scanner, notifier: FakeLostNotifier(), location: FixedLocationProvider(), sightingStore: store, activity: FakeSearchActivity(), myDevicesStore: mineStore, defaults: defaults)
    }

    private func setReadable(_ readable: Bool, _ url: URL) throws {
        try FileManager.default.setAttributes([.posixPermissions: readable ? 0o644 : 0o000], ofItemAtPath: url.path())
    }

    @Test func savedDevicesThatCannotBeReadAreNotSavedOver() throws {
        mineStore.save(saved)
        try setReadable(false, mineStore.url)
        defer { try? setReadable(true, mineStore.url) }
        let model = makeModel()
        #expect(model.myDevices.isEmpty)

        model.handle(.advertisement(.fixture(device: 2, name: "Altro")))
        model.refresh(at: Advertisement.start)
        try model.saveDevice(#require(model.devices.first), name: "Altro mio")

        try setReadable(true, mineStore.url)
        #expect(mineStore.load() == saved)
    }

    @Test func onceReadableTheSavedDevicesComeBackWithTheOnesAddedMeanwhile() throws {
        mineStore.save(saved)
        try setReadable(false, mineStore.url)
        defer { try? setReadable(true, mineStore.url) }
        let model = makeModel()
        model.handle(.advertisement(.fixture(device: 2, name: "Altro")))
        model.refresh(at: Advertisement.start)
        try model.saveDevice(#require(model.devices.first), name: "Altro mio")

        try setReadable(true, mineStore.url)
        model.reloadUnavailableFiles()

        #expect(model.myDevices.map(\.name) == ["Il mio orologio", "Altro mio"])
        #expect(mineStore.load().map(\.name) == ["Il mio orologio", "Altro mio"])
    }

    @Test func sightingsThatCannotBeReadComeBackOnceReadable() throws {
        var log = SightingLog()
        log.record(.fixture(device: 1))
        store.save(log)
        try setReadable(false, store.url)
        defer { try? setReadable(true, store.url) }
        let model = makeModel()
        #expect(model.sightings.sightings.isEmpty)

        try setReadable(true, store.url)
        model.reloadUnavailableFiles()

        #expect(model.sightings.latest(id: Advertisement.testID(1)) != nil)
        #expect(store.load() == log)
    }

    /// Cancella le posizioni is asked for: it erases the file even if it could not be read.
    @Test func forgettingPlacesErasesEvenAnUnreadableFile() throws {
        var log = SightingLog()
        log.record(.fixture(device: 1))
        store.save(log)
        try setReadable(false, store.url)
        defer { try? setReadable(true, store.url) }
        let model = makeModel()

        model.forgetPlaces()
        model.reloadUnavailableFiles()

        #expect(store.load().sightings.isEmpty)
        #expect(model.sightings.sightings.isEmpty)
    }
}
