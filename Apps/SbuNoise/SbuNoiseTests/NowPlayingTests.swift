import Foundation
import Testing
@testable import SbuNoise

struct NowPlayingTests {
    private let url = URL.temporaryDirectory.appending(path: "NowPlayingTests-\(UUID().uuidString)/now-playing.json")

    @Test func nothingSavedLoadsAPausedPlayerWithNothingChosen() {
        #expect(NowPlaying.load(from: url) == NowPlaying())
    }

    @Test func savedStateLoadsBack() throws {
        let nowPlaying = NowPlaying(name: "Temporale", systemImage: "square.stack.3d.up", isPlaying: true)
        try nowPlaying.save(to: url)
        #expect(NowPlaying.load(from: url) == nowPlaying)
    }

    @Test(arguments: [true, false])
    func takesTheItemAndPlayback(isPlaying: Bool) {
        let item = PlayerItem.sound(Sound.generated[2])
        #expect(NowPlaying(item, isPlaying: isPlaying) == NowPlaying(name: item.name, systemImage: item.systemImage, isPlaying: isPlaying))
    }

    @Test func anEmptyCategoryHasNoName() {
        #expect(NowPlaying(nil, isPlaying: false).name == nil)
    }

    @Test func widgetSyncWritesWhatThePlayerShows() async throws {
        let model = PlayerModel(library: Library(store: .temporary), defaults: UserDefaults(suiteName: UUID().uuidString)!)
        let sync = WidgetSync(model: model, url: url)
        #expect(NowPlaying.load(from: url) == NowPlaying(model.current, isPlaying: false))

        model.perform(.play(itemID: "noise.brown"))
        // The observer writes on the next turn of the main actor.
        try await Task.sleep(for: .milliseconds(100))
        #expect(NowPlaying.load(from: url) == NowPlaying(model.current, isPlaying: true))
        withExtendedLifetime(sync) {}
    }
}
