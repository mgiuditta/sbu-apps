import WidgetKit

nonisolated struct NowPlayingEntry: TimelineEntry {
    let date: Date
    let nowPlaying: NowPlaying
}
