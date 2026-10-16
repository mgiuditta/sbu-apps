import Foundation
import Testing
@testable import SbuGrid

/// The photo file and the saved choices, each test in its own folder and defaults suite.
struct StoreTests {
    let directory: URL
    let defaults: UserDefaults
    let suite: String

    init() throws {
        directory = URL.temporaryDirectory.appending(path: "StoreTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        suite = "StoreTests-\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suite))
    }

    @Test func noPhotoBeforeOneIsSaved() {
        #expect(PhotoStore(directory: directory).load() == nil)
    }

    @Test func aSavedPhotoComesBackAtItsSize() throws {
        let store = PhotoStore(directory: directory)
        try store.save(TestImage.make(width: 120, height: 90))
        let photo = try #require(store.load())
        #expect(photo.width == 120)
        #expect(photo.height == 90)
    }

    @Test func aNewPhotoReplacesTheOldOne() throws {
        let store = PhotoStore(directory: directory)
        try store.save(TestImage.make(width: 120, height: 90))
        try store.save(TestImage.make(width: 30, height: 60))
        #expect(store.load()?.width == 30)
    }

    @Test func aRemovedPhotoIsGone() throws {
        let store = PhotoStore(directory: directory)
        try store.save(TestImage.make(width: 12, height: 9))
        store.remove()
        #expect(store.load() == nil)
        // Removing twice is fine.
        store.remove()
    }

    @Test func aDamagedFileReadsAsNoPhoto() throws {
        let store = PhotoStore(directory: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("damaged".utf8).write(to: store.photoURL)
        #expect(store.load() == nil)
    }

    @Test func theStandardStoreIsInApplicationSupport() {
        #expect(PhotoStore.standard.photoURL.path(percentEncoded: false).contains("Application Support"))
        #expect(PhotoStore.standard.photoURL.lastPathComponent == "photo.jpg")
    }

    @Test func nothingSavedLoadsTheDefaults() {
        #expect(StateStore(defaults: defaults).load() == GridState())
    }

    @Test func savedChoicesComeBack() {
        let store = StateStore(defaults: defaults)
        var state = GridState()
        state.settings.columns = 13
        state.settings.showsNumbers = true
        store.save(state)
        #expect(StateStore(defaults: defaults).load() == state)
    }

    @Test func damagedChoicesLoadTheDefaults() {
        defaults.set(Data("{".utf8), forKey: "gridState")
        #expect(StateStore(defaults: defaults).load() == GridState())
    }

    @Test func aDamagedPartKeepsTheRest() throws {
        let json = #"{"settings": {"columns": "nine"}}"#
        let state = try JSONDecoder().decode(GridState.self, from: Data(json.utf8))
        #expect(state.settings == GridSettings())
    }

    @Test func removedChoicesAreForgotten() {
        let store = StateStore(defaults: defaults)
        var state = GridState()
        state.settings.columns = 2
        store.save(state)
        store.remove()
        #expect(store.load() == GridState())
    }

    @Test func eachKeyIsItsOwnState() {
        var state = GridState()
        state.settings.columns = 2
        StateStore(defaults: defaults, key: "a").save(state)
        #expect(StateStore(defaults: defaults, key: "b").load() == GridState())
    }
}
