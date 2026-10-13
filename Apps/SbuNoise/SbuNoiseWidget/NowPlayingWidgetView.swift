import SbuKit
import SwiftUI
import WidgetKit

/// On the Home Screen, the sound's name as the widget's one figure, closed by the full stop, with
/// its symbol and the play/pause button; on the Lock Screen, the button alone or with the name.
struct NowPlayingWidgetView: View {
    let nowPlaying: NowPlaying

    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    PlayPauseButton(isPlaying: nowPlaying.isPlaying, filled: false)
                }
            case .accessoryRectangular:
                HStack(spacing: SbuTheme.space2) {
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.headline)
                            .widgetAccentable()
                        Text(nowPlaying.isPlaying ? "In riproduzione" : "In pausa")
                            .font(.caption)
                    }
                    Spacer(minLength: 0)
                    PlayPauseButton(isPlaying: nowPlaying.isPlaying, filled: false)
                }
            case .systemMedium:
                HStack(alignment: .bottom, spacing: SbuTheme.space4) {
                    symbol
                    NowPlayingFigure(name: name)
                    PlayPauseButton(isPlaying: nowPlaying.isPlaying, filled: true)
                }
            default:
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    HStack(alignment: .top) {
                        symbol
                        Spacer(minLength: 0)
                        PlayPauseButton(isPlaying: nowPlaying.isPlaying, filled: true)
                    }
                    Spacer(minLength: 0)
                    NowPlayingFigure(name: name)
                }
            }
        }
        .tint(SbuTheme.accentNoise)
        .containerBackground(for: .widget) {
            // The Lock Screen shows its wallpaper through the accessory widgets.
            if family == .systemSmall || family == .systemMedium {
                SbuTheme.surface
            }
        }
    }

    private var name: String {
        nowPlaying.name ?? "Sbu Noise"
    }

    private var symbol: some View {
        Image(systemName: nowPlaying.systemImage ?? "waveform")
            .font(.title2.weight(.medium))
            .foregroundStyle(SbuTheme.inkMuted)
            .accessibilityHidden(true)
    }
}
