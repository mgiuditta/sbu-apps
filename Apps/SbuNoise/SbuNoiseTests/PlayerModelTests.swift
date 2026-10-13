import Foundation
import Testing
@testable import SbuNoise

struct PlayerModelTests {
    private let defaults = UserDefaults(suiteName: UUID().uuidString)!

    @Test func opensOnTheFirstSoundTheFirstTime() {
        #expect(PlayerModel(defaults: defaults).current.id == Sound.generated[0].id)
    }

    @Test func reopensOnTheLastSound() {
        PlayerModel(defaults: defaults).index = 3
        #expect(PlayerModel(defaults: defaults).current.id == Sound.generated[3].id)
    }

    @Test func forgetsALastSoundThatNoLongerExists() {
        defaults.set("gone", forKey: PlayerModel.lastSoundKey)
        #expect(PlayerModel(defaults: defaults).index == 0)
    }

    @Test(arguments: [(0, -1, 4), (4, 1, 0), (2, 1, 3), (2, -1, 1)])
    func stepWrapsAtTheEnds(from start: Int, offset: Int, expected: Int) {
        let model = PlayerModel(defaults: defaults)
        model.index = start
        model.step(offset)
        #expect(model.index == expected)
    }

    @Test func playbackTogglesAndFollowsTheSwipe() {
        let model = PlayerModel(defaults: defaults)
        model.togglePlayback()
        #expect(model.isPlaying)
        model.step(1)
        #expect(model.isPlaying)
        model.togglePlayback()
        #expect(!model.isPlaying)
    }

    @Test func favoriteToggles() {
        let model = PlayerModel(defaults: defaults)
        model.toggleFavorite(model.current)
        #expect(model.isFavorite(model.current))
        model.toggleFavorite(model.current)
        #expect(!model.isFavorite(model.current))
    }

    @Test func remoteCommandsDriveThePlayer() {
        let model = PlayerModel(defaults: defaults)
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
        let model = PlayerModel(defaults: defaults)
        model.handle(.play)
        model.handle(.interruptionBegan)
        #expect(!model.isPlaying)
        model.handle(.interruptionEnded(shouldResume: shouldResume))
        #expect(model.isPlaying == shouldResume)
    }

    @Test func staysPausedAfterAnInterruptionIfItWasPaused() {
        let model = PlayerModel(defaults: defaults)
        model.handle(.interruptionBegan)
        model.handle(.interruptionEnded(shouldResume: true))
        #expect(!model.isPlaying)
    }

    @Test func aPauseDuringTheInterruptionWins() {
        let model = PlayerModel(defaults: defaults)
        model.handle(.play)
        model.handle(.interruptionBegan)
        model.handle(.pause)
        model.handle(.interruptionEnded(shouldResume: true))
        #expect(!model.isPlaying)
    }

    @Test func pausesWhenTheHeadphonesGo() {
        let model = PlayerModel(defaults: defaults)
        model.handle(.play)
        model.handle(.outputLost)
        #expect(!model.isPlaying)
    }
}
