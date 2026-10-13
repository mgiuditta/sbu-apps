import AppIntents
import SbuKit
import SwiftUI
import WidgetKit

/// Play/pause in Control Center, on the Lock Screen and the Action button, from iOS 18.
@available(iOS 18, *)
struct PlaybackControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: NowPlaying.controlKind, provider: Provider()) { nowPlaying in
            ControlWidgetToggle(isOn: nowPlaying.isPlaying, action: SetPlayingIntent()) {
                Text(nowPlaying.name ?? "Sbu Noise")
            } valueLabel: { isOn in
                Label(isOn ? "In riproduzione" : "In pausa", systemImage: isOn ? "speaker.wave.2.fill" : "speaker.fill")
            }
            .tint(SbuTheme.accentNoise)
        }
        .displayName("Riproduci un suono")
        .description("Avvia o metti in pausa il suono di Sbu Noise.")
    }

    struct Provider: ControlValueProvider {
        var previewValue: NowPlaying { .sample }

        func currentValue() async throws -> NowPlaying {
            NowPlaying.load()
        }
    }
}
