import SwiftUI
import WidgetKit

/// The sound on screen and its play/pause button, on the Home Screen and the Lock Screen.
struct NowPlayingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: NowPlaying.widgetKind, provider: NowPlayingProvider()) { entry in
            NowPlayingWidgetView(nowPlaying: entry.nowPlaying)
        }
        .configurationDisplayName("In riproduzione")
        .description("Il suono che stai ascoltando, da avviare o mettere in pausa.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

#Preview("Piccolo", as: .systemSmall) {
    NowPlayingWidget()
} timeline: {
    NowPlayingEntry(date: .now, nowPlaying: .sample)
    NowPlayingEntry(date: .now, nowPlaying: NowPlaying(name: "Rumore marrone", systemImage: "water.waves", isPlaying: true))
}

#Preview("Medio", as: .systemMedium) {
    NowPlayingWidget()
} timeline: {
    NowPlayingEntry(date: .now, nowPlaying: NowPlaying(name: "Temporale", systemImage: "square.stack.3d.up", isPlaying: true))
}

#Preview("Circolare", as: .accessoryCircular) {
    NowPlayingWidget()
} timeline: {
    NowPlayingEntry(date: .now, nowPlaying: .sample)
}

#Preview("Rettangolare", as: .accessoryRectangular) {
    NowPlayingWidget()
} timeline: {
    NowPlayingEntry(date: .now, nowPlaying: .sample)
}
