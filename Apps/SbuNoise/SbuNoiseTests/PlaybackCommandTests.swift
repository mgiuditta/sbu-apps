import Foundation
import Testing
@testable import SbuNoise

struct PlaybackCommandTests {
    private let defaults = UserDefaults(suiteName: UUID().uuidString)!
    private let library = Library(store: .temporary)

    private func model() -> PlayerModel {
        PlayerModel(sounds: Sound.generated, library: library, defaults: defaults)
    }

    @Test func playWithNoItemPlaysTheSoundOnScreen() {
        let model = model()
        model.index = 2
        model.perform(.play(itemID: nil))
        #expect(model.isPlaying)
        #expect(model.current?.id == Sound.generated[2].id)
    }

    @Test func playASoundMovesToItsPage() {
        let model = model()
        model.perform(.play(itemID: "noise.brown"))
        #expect(model.isPlaying)
        #expect(model.category == .sounds)
        #expect(model.current?.id == "noise.brown")
    }

    @Test func playAMixMovesToTheMixCategory() {
        let mix = Mix(name: "Temporale", soundIDs: ["noise.pink", "noise.brown"])
        library.save(Mix(name: "Mare", soundIDs: ["noise.white"]))
        library.save(mix)
        let model = model()
        model.perform(.play(itemID: mix.id.uuidString))
        #expect(model.isPlaying)
        #expect(model.category == .mixes)
        #expect(model.current?.id == mix.id.uuidString)
    }

    @Test func anUnknownItemPlaysTheSoundOnScreen() {
        let model = model()
        model.index = 1
        model.perform(.play(itemID: "gone"))
        #expect(model.isPlaying)
        #expect(model.current?.id == Sound.generated[1].id)
    }

    @Test func playingAnotherSoundKeepsPlaying() {
        let model = model()
        model.perform(.play(itemID: nil))
        model.perform(.play(itemID: "noise.violet"))
        #expect(model.isPlaying)
        #expect(model.current?.id == "noise.violet")
    }

    @Test func pauseStops() {
        let model = model()
        model.perform(.play(itemID: nil))
        model.perform(.pause)
        #expect(!model.isPlaying)
    }

    @Test func theCommandsReachTheHandler() {
        var received: [PlaybackCommand] = []
        PlaybackCommands.handler = { received.append($0) }
        defer { PlaybackCommands.handler = nil }
        PlaybackCommands.send(.pause)
        PlaybackCommands.send(.play(itemID: "noise.pink"))
        #expect(received == [.pause, .play(itemID: "noise.pink")])
    }
}
