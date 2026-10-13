import Foundation
import Testing
@testable import SbuNoise

/// Gestisci and the groups of the ☰ menu, through the player.
struct ManageTests {
    private let defaults = UserDefaults(suiteName: UUID().uuidString)!

    private func model(sounds: [Sound] = Sound.generated) -> PlayerModel {
        PlayerModel(sounds: sounds, library: Library(store: .temporary), defaults: defaults)
    }

    @Test func aGroupListsOnlyItsSounds() {
        let model = model(sounds: Sound.catalog)
        model.category = .group(.water)
        #expect(!model.items.isEmpty)
        #expect(model.items.allSatisfy { item in
            if case .sound(let sound) = item { sound.category == .water } else { false }
        })
    }

    @Test(arguments: [PlayerCategory.sounds, .favorites, .mixes, .group(.rain), .group(.travel)])
    func theCategoryIsRememberedByName(category: PlayerCategory) {
        #expect(PlayerCategory(rawValue: category.rawValue) == category)
        model().category = category
        #expect(model().category == category)
    }

    @Test func hidingThePlayingSoundMovesToItsNeighbor() throws {
        let model = model()
        model.index = 1
        model.togglePlayback()
        let pink = try #require(model.sound(withID: "noise.pink"))

        model.hide(pink)
        #expect(!model.items.contains { $0.id == "noise.pink" })
        #expect(model.current?.id == "noise.brown")
        #expect(model.isPlaying)

        model.show(pink)
        #expect(model.current?.id == "noise.brown", "Showing it again keeps the page")
    }

    @Test func reorderingKeepsTheSoundOnScreen() {
        let model = model()
        model.index = 0
        model.moveSounds(fromOffsets: IndexSet(integer: 0), toOffset: 5)
        #expect(model.items.last?.id == "noise.white")
        #expect(model.current?.id == "noise.white")
    }

    @Test func changingListKeepsTheSoundOnScreenIfTheNewListHasIt() {
        let model = model(sounds: Sound.catalog)
        model.playItem(withID: "water.ocean")
        model.category = .group(.water)
        #expect(model.current?.id == "water.ocean")
        #expect(model.isPlaying, "The same sound keeps playing")
        model.category = .group(.rain)
        #expect(model.index == 0, "A list without it starts at its first sound")
    }

    @Test func aTapInGestisciPlaysTheSound() {
        let model = model()
        model.category = .mixes
        model.playItem(withID: "noise.blue")
        #expect(model.category == .sounds)
        #expect(model.current?.id == "noise.blue")
        #expect(model.isPlaying)
    }

    @Test func aRecordingPlays() throws {
        let model = model(sounds: Sound.catalog)
        let loop = try #require(Sound.catalog.first { $0.source.isLoop })
        model.playItem(withID: loop.id)
        #expect(model.isPlaying)
        #expect(model.current?.id == loop.id)
    }
}
