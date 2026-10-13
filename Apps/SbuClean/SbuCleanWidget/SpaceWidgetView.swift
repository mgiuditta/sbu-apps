import SbuKit
import SwiftUI
import WidgetKit

/// The free space on paper: the figure closed by the full stop, what you can free under it,
/// and on the medium size the storage bar.
struct SpaceWidgetView: View {
    let entry: SpaceEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        HStack(alignment: .bottom, spacing: SbuTheme.space4) {
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text("Spazio libero")
                    .font(SbuTheme.caption)
                    .textCase(.uppercase)
                    .tracking(SbuTheme.captionTracking)
                    .foregroundStyle(SbuTheme.inkMuted)

                if let storage = entry.storage {
                    SpaceWidgetFigure(bytes: storage.availableBytes)
                }

                freeable
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            if family == .systemMedium, let storage = entry.storage {
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    Text("\(storage.usedBytes.formatted(.byteCount(style: .file))) usati su \(storage.totalBytes.formatted(.byteCount(style: .file)))")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                    ProgressView(value: storage.usedFraction)
                        .widgetAccentable()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.large)
        .tint(SbuTheme.accentClean)
        .containerBackground(for: .widget) {
            SbuTheme.surface
        }
    }

    @ViewBuilder private var freeable: some View {
        if let bytes = entry.freeableBytes {
            Text("Puoi liberare \(bytes.formatted(.byteCount(style: .file)))")
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        } else {
            Text("Apri Sbu Clean per cercare")
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
    }
}

#Preview("Piccolo", as: .systemSmall) {
    SpaceWidget()
} timeline: {
    SpaceEntry.sample
    SpaceEntry(date: .now, storage: SpaceEntry.sample.storage, freeableBytes: nil)
}

#Preview("Medio", as: .systemMedium) {
    SpaceWidget()
} timeline: {
    SpaceEntry.sample
}
