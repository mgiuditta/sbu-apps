import SbuKit
import SwiftUI
import WidgetKit

/// The sound's name as the widget's one figure, its full stop set while it plays, with the
/// play/pause button; on the Lock Screen's circle, the button alone.
struct NowPlayingWidgetView: View {
    let nowPlaying: NowPlaying

    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                PlayPauseButton(isPlaying: nowPlaying.isPlaying, filled: false)
            }
            // The Lock Screen shows its wallpaper through the accessory widgets.
            .containerBackground(for: .widget) {}
        case .accessoryRectangular:
            HStack(spacing: SbuTheme.space2) {
                figure
                PlayPauseButton(isPlaying: nowPlaying.isPlaying, filled: false)
            }
        default:
            figure
                .overlay(alignment: .topTrailing) {
                    PlayPauseButton(isPlaying: nowPlaying.isPlaying, filled: true)
                }
        }
    }

    private var figure: some View {
        SbuWidgetFigure(
            value: nowPlaying.name ?? "Sbu Noise",
            label: nowPlaying.isPlaying ? Text("In riproduzione") : Text("In pausa"),
            fullStop: nowPlaying.isPlaying ? .set : .waiting,
            accent: .noise
        )
    }
}

#Preview("Light", as: .systemSmall) {
    NowPlayingWidget()
} timeline: {
    NowPlayingEntry(date: .now, nowPlaying: NowPlaying(name: "Rumore marrone", systemImage: "water.waves", isPlaying: true))
}

#Preview("Dark", as: .systemMedium) {
    NowPlayingWidget()
} timeline: {
    NowPlayingEntry(date: .now, nowPlaying: .sample)
}
