import Foundation
import Testing
@testable import SbuNoise

struct PlayerModelTests {
    private let defaults = UserDefaults(suiteName: UUID().uuidString)!
    private let library = Library(store: .temporary)

    private func model() -> PlayerModel {
        PlayerModel(sounds: Sound.generated, library: library, defaults: defaults)
    }

    @Test func opensOnTheFirstSoundTheFirstTime() {
        #expect(model().current?.id == Sound.generated[0].id)
    }

    @Test func reopensOnTheLastSound() {
        model().index = 3
        #expect(model().current?.id == Sound.generated[3].id)
    }

    @Test func forgetsALastSoundThatNoLongerExists() {
        defaults.set("gone", forKey: PlayerModel.lastSoundKey)
        #expect(model().index == 0)
    }

    @Test(arguments: [(0, -1, 4), (4, 1, 0), (2, 1, 3), (2, -1, 1)])
    func stepWrapsAtTheEnds(from start: Int, offset: Int, expected: Int) {
        let model = model()
        model.index = start
        model.step(offset)
        #expect(model.index == expected)
    }

    @Test func playbackTogglesAndFollowsTheSwipe() {
        let model = model()
        model.togglePlayback()
        #expect(model.isPlaying)
        model.step(1)
        #expect(model.isPlaying)
        model.togglePlayback()
        #expect(!model.isPlaying)
    }

    @Test func favoriteToggles() {
        let model = model()
        let current = try! #require(model.current)
        model.toggleFavorite(current)
        #expect(model.isFavorite(current))
        model.toggleFavorite(current)
        #expect(!model.isFavorite(current))
    }

    @Test func remoteCommandsDriveThePlayer() {
        let model = model()
        model.handle(.play)
        model.handle(.play)
        #expect(model.isPlaying)
        model.handle(.next)
        #expect(model.index == 1)
        model.handle(.previous)
        #expect(model.index == 0)
        model.handle(.togglePlayPause)
        #expect(!model.isPlaying)
        model.handle(.pause)
        #expect(!model.isPlaying)
    }

    @Test(arguments: [true, false])
    func resumesAfterAnInterruptionOnlyWhenTheSystemSays(shouldResume: Bool) {
        let model = model()
        model.handle(.play)
        model.handle(.interruptionBegan)
        #expect(!model.isPlaying)
        model.handle(.interruptionEnded(shouldResume: shouldResume))
        #expect(model.isPlaying == shouldResume)
    }

    @Test func staysPausedAfterAnInterruptionIfItWasPaused() {
        let model = model()
        model.handle(.interruptionBegan)
        model.handle(.interruptionEnded(shouldResume: true))
        #expect(!model.isPlaying)
    }

    @Test func aPauseDuringTheInterruptionWins() {
        let model = model()
        model.handle(.play)
        model.handle(.interruptionBegan)
        model.handle(.pause)
        model.handle(.interruptionEnded(shouldResume: true))
        #expect(!model.isPlaying)
    }

    @Test func pausesWhenTheHeadphonesGo() {
        let model = model()
        model.handle(.play)
        model.handle(.outputLost)
        #expect(!model.isPlaying)
    }

    // MARK: Mixes

    @Test func anEmptyMixCategoryHasNothingToPlay() {
        let model = model()
        model.category = .mixes
        #expect(model.current == nil)
        model.step(1)
        model.togglePlayback()
        #expect(!model.isPlaying)
    }

    @Test func aSavedMixPlaysFromItsPageAndIsRemembered() {
        let model = model()
        let mix = Mix(name: "Temporale", soundIDs: ["noise.pink", "noise.brown"])
        model.saveAndPlay(mix)
        #expect(model.category == .mixes)
        #expect(model.current?.id == mix.id.uuidString)
        #expect(model.isPlaying)

        let reopened = PlayerModel(library: Library(store: .temporary), defaults: defaults)
        #expect(reopened.category == .mixes)
    }

    @Test func theMixPadPlaysTheDraftThenGivesThePageBack() {
        let model = model()
        model.preview(Mix(name: "Bozza", soundIDs: ["noise.white"]))
        #expect(model.isPlaying)
        var draft = Mix(name: "Bozza", soundIDs: ["noise.white", "noise.blue"])
        draft.layers[0].variance = 0.4
        model.preview(draft)
        #expect(model.isPlaying)
        model.endPreview()
        #expect(model.isPlaying)
        #expect(model.current?.id == Sound.generated[0].id)
    }

    @Test func deletingThePlayingMixStopsAndStaysOnAValidPage() {
        let model = model()
        let first = Mix(name: "Uno", soundIDs: ["noise.pink"])
        let second = Mix(name: "Due", soundIDs: ["noise.brown"])
        library.save(first)
        model.saveAndPlay(second)
        model.delete(second)
        #expect(!model.isPlaying)
        #expect(model.current?.id == first.id.uuidString)
    }
}
