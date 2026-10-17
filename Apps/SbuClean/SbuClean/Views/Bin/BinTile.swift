import SbuKit
import SwiftUI

/// One item in the bin: a square thumbnail with the bin mark; tapping it takes it out.
struct BinTile: View {
    let item: MediaItem
    let restore: () -> Void

    var body: some View {
        Button(action: restore) {
            MediaThumbnail(id: item.id)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    SelectionMark(isSelected: true)
                }
                .overlay(alignment: .bottomLeading) {
                    if item.kind == .video {
                        Text(item.durationText)
                            .font(SbuTheme.caption)
                            .monospacedDigit()
                            .foregroundStyle(SbuTheme.ink)
                            .padding(.horizontal, SbuTheme.space1)
                            .background(SbuTheme.paper, in: .rect(cornerRadius: SbuTheme.radiusSm))
                            .padding(SbuTheme.space1)
                            .accessibilityHidden(true)
                    }
                }
                .clipShape(.rect(cornerRadius: SbuTheme.radiusSm))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.spokenDescription)
        .accessibilityHint("Toglie dal cestino")
    }
}

#Preview("Light") {
    BinTile(item: MediaItem(id: "photo-3", kind: .photo)) {}
        .frame(width: 120)
        .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    BinTile(item: MediaItem(id: "video-1", kind: .video, duration: 48)) {}
        .frame(width: 120)
        .environment(\.sbuAccent, .clean)
        .preferredColorScheme(.dark)
}
