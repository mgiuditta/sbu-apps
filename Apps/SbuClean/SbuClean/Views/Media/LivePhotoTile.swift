import SbuKit
import SwiftUI

/// A Live Photo with its size before and after the conversion.
struct LivePhotoTile: View {
    let item: MediaItem
    let isSelected: Bool
    let toggle: () -> Void

    private var before: Int64 {
        item.bytes
    }

    private var after: Int64 {
        item.bytes - (item.size?.pairedVideoBytes ?? 0)
    }

    var body: some View {
        Button(action: toggle) {
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                MediaThumbnail(id: item.id, side: 150)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(alignment: .topTrailing) {
                        SelectionMark(isSelected: isSelected)
                    }
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "livephoto")
                            .fontWeight(.medium)
                            .foregroundStyle(SbuTheme.ink)
                            .padding(SbuTheme.space1)
                            .background(Circle().fill(SbuTheme.surface))
                            .padding(SbuTheme.space1)
                    }
                    .clipShape(.rect(cornerRadius: SbuTheme.radiusMd))

                Text("Prima \(before.formatted(.byteCount(style: .file))), dopo \(after.formatted(.byteCount(style: .file)))")
                    .font(SbuTheme.caption)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityValue(isSelected ? Text("Da convertire") : Text("Da lasciare così"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    LivePhotoTile(item: MediaItem(id: "live-0", kind: .photo, isLivePhoto: true, size: ItemSize(bytes: 5_600_000, pairedVideoBytes: 2_400_000)), isSelected: true) {}
        .frame(width: 160)
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    LivePhotoTile(item: MediaItem(id: "live-1", kind: .photo, isLivePhoto: true, size: ItemSize(bytes: 5_600_000, pairedVideoBytes: 2_400_000)), isSelected: false) {}
        .frame(width: 160)
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
