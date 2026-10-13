import WidgetKit

/// One entry with what the app last wrote; the app reloads the widget when it changes.
struct NowPlayingProvider: TimelineProvider {
    func placeholder(in context: Context) -> NowPlayingEntry {
        NowPlayingEntry(date: .now, nowPlaying: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (NowPlayingEntry) -> Void) {
        let saved = NowPlaying.load()
        completion(NowPlayingEntry(date: .now, nowPlaying: context.isPreview && saved.name == nil ? .sample : saved))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NowPlayingEntry>) -> Void) {
        completion(Timeline(entries: [NowPlayingEntry(date: .now, nowPlaying: NowPlaying.load())], policy: .never))
    }
}
