import AppIntents
import SbuKit
import SwiftUI
import WidgetKit

/// Volume, mute, play/pause and power for the last TV used, on paper like the app.
struct RemoteWidgetView: View {
    let entry: RemoteWidgetEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Text(entry.tvName ?? String(localized: "Nessuna TV"))
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
            if entry.tvName == nil {
                Text("Aggiungi una TV in Sbu Remote.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                Spacer(minLength: 0)
            } else if family == .systemSmall {
                Grid(horizontalSpacing: SbuTheme.space2, verticalSpacing: SbuTheme.space2) {
                    GridRow {
                        WidgetKeyButton(intent: VolumeDownIntent(), key: .volumeDown)
                        WidgetKeyButton(intent: VolumeUpIntent(), key: .volumeUp)
                    }
                    GridRow {
                        WidgetKeyButton(intent: MuteIntent(), key: .mute)
                        WidgetKeyButton(intent: PowerIntent(), key: .power)
                    }
                }
            } else {
                HStack(spacing: SbuTheme.space2) {
                    WidgetKeyButton(intent: VolumeDownIntent(), key: .volumeDown)
                    WidgetKeyButton(intent: VolumeUpIntent(), key: .volumeUp)
                    WidgetKeyButton(intent: MuteIntent(), key: .mute)
                    WidgetKeyButton(intent: PlayPauseIntent(), key: .playPause)
                    WidgetKeyButton(intent: PowerIntent(), key: .power)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            SbuTheme.surface
        }
        .tint(SbuTheme.accentRemote)
    }
}

/// One key of the widget: the intent runs in the app, which reaches the TV.
private struct WidgetKeyButton<Intent: AppIntent>: View {
    let intent: Intent
    let key: RemoteKey

    var body: some View {
        Button(intent: intent) {
            Image(systemName: key.systemImage)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: SbuTheme.radiusMd))
        .widgetAccentable()
        .accessibilityLabel(Text(key.title))
    }
}

#Preview("Small", as: .systemSmall) {
    RemoteWidget()
} timeline: {
    RemoteWidgetEntry(date: .now, tvName: "Soggiorno")
    RemoteWidgetEntry(date: .now, tvName: nil)
}

#Preview("Medium", as: .systemMedium) {
    RemoteWidget()
} timeline: {
    RemoteWidgetEntry(date: .now, tvName: "Soggiorno")
}
