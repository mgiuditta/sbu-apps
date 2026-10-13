import Foundation
import Testing
@testable import SbuNoise

struct FavoritesTests {
    private let store = NoiseStore.temporary
    private let defaults = UserDefaults(suiteName: UUID().uuidString)!

    private func model() -> PlayerModel {
        PlayerModel(sounds: Sound.generated, library: Library(store: store), defaults: defaults)
    }

    @Test func heartsAreSavedInTheNoiseFile() throws {
        let model = model()
        let current = try #require(model.current)
        model.toggleFavorite(current)

        #expect(try store.load().favorites == [current.id])
        #expect(self.model().isFavorite(current), "A new launch still has the heart")
    }

    @Test func favoritesListSoundsAndMixesInTheOrderTheyWereAdded() throws {
        let model = model()
        let mix = Mix(name: "Temporale", soundIDs: ["noise.pink"])
        model.library.save(mix)
        model.library.toggleFavorite("noise.brown")
        model.library.toggleFavorite(mix.id.uuidString)
        model.library.toggleFavorite("gone")

        model.category = .favorites
        #expect(model.items.map(\.id) == ["noise.brown", mix.id.uuidString], "An id that no longer exists is skipped")
    }

    @Test func removingTheHeartInFavoritesMovesToTheNeighbor() throws {
        let model = model()
        for id in ["noise.white", "noise.pink", "noise.brown"] { model.library.toggleFavorite(id) }
        model.category = .favorites
        model.index = 1
        model.togglePlayback()

        model.toggleFavorite(try #require(model.current))
        #expect(model.items.map(\.id) == ["noise.white", "noise.brown"])
        #expect(model.current?.id == "noise.brown")
        #expect(model.isPlaying, "The neighbor plays in its place")
    }

    @Test func aHeartOutsideFavoritesKeepsThePage() throws {
        let model = model()
        model.index = 2
        model.toggleFavorite(try #require(model.current))
        #expect(model.index == 2)
    }

    @Test func deletingAMixTakesItsHeartAway() {
        let library = Library(store: store)
        let mix = Mix(name: "Uno", soundIDs: ["noise.pink"])
        library.save(mix)
        library.toggleFavorite(mix.id.uuidString)
        library.delete(mix.id)
        #expect(library.favorites.isEmpty)
    }

    @Test func anOldFileWithoutFavoritesLoadsWithNone() throws {
        let old = Data(#"{"version": 1, "timers": [], "mixes": []}"#.utf8)
        try FileManager.default.createDirectory(at: store.url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try old.write(to: store.url)
        #expect(try store.load().favorites.isEmpty)
    }
}
