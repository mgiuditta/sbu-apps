import SbuKit
import SwiftUI

/// A square in a selectable grid, with its size, and the length of a video.
struct MediaGridTile: View {
    let item: MediaItem
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            MediaThumbnail(id: item.id)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    SelectionMark(isSelected: isSelected)
                }
                .overlay(alignment: .bottomLeading) {
                    Text(item.kind == .video ? item.durationText : item.bytes.sizeText)
                        .font(SbuTheme.caption)
                        .monospacedDigit()
                        .foregroundStyle(SbuTheme.ink)
                        .padding(.horizontal, SbuTheme.space1)
                        .background(SbuTheme.surface, in: .rect(cornerRadius: SbuTheme.radiusSm))
                        .padding(SbuTheme.space1)
                        .accessibilityHidden(true)
                }
                .clipShape(.rect(cornerRadius: SbuTheme.radiusSm))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.spokenDescription)
        .accessibilityValue(isSelected ? Text("Da eliminare") : Text("Da tenere"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    MediaGridTile(item: MediaItem(id: "screenshot-0", kind: .photo, isScreenshot: true, size: ItemSize(bytes: 900_000)), isSelected: true) {}
        .frame(width: 120)
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    MediaGridTile(item: MediaItem(id: "recording-0", kind: .video, isScreenRecording: true, duration: 22), isSelected: false) {}
        .frame(width: 120)
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
