import SbuKit
import SwiftUI

/// A video in the list: its frame (tap to play), size and length, date, and the selection.
/// Swipe or long press for Comprimi.
struct VideoRow: View {
    let item: MediaItem
    let isSelected: Bool
    let toggle: () -> Void
    let play: () -> Void

    @ScaledMetric(relativeTo: .body) private var thumbnailSide: CGFloat = 64
    @ScaledMetric(relativeTo: .title2) private var amountSize = SbuTheme.statSmallSize

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            Button(action: play) {
                MediaThumbnail(id: item.id, side: thumbnailSide)
                    .frame(width: thumbnailSide, height: thumbnailSide)
                    .overlay {
                        Image(systemName: "play.fill")
                            .fontWeight(.medium)
                            .foregroundStyle(SbuTheme.ink)
                            .padding(SbuTheme.space2)
                            .background(Circle().fill(SbuTheme.surface))
                    }
                    .clipShape(.rect(cornerRadius: SbuTheme.radiusSm))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Riproduci")

            Button(action: toggle) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.bytes.formatted(.byteCount(style: .file)))
                            .font(SbuTheme.smallNumberFont(size: amountSize))
                            .foregroundStyle(SbuTheme.ink)
                        Text("\(item.durationText) · \(item.creationDate?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    Spacer(minLength: SbuTheme.space2)
                    Image(systemName: isSelected ? "trash.circle.fill" : "circle")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(SbuTheme.inkMuted))
                        .accessibilityHidden(true)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.spokenDescription)
            .accessibilityValue(isSelected ? Text("Da eliminare") : Text("Da tenere"))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
        .swipeActions(edge: .trailing) {
            NavigationLink(value: Route.compress(item.id)) {
                Label("Comprimi", systemImage: "arrow.down.right.and.arrow.up.left")
            }
            .tint(SbuTheme.inkMuted)
        }
        .contextMenu {
            NavigationLink(value: Route.compress(item.id)) {
                Label("Comprimi", systemImage: "arrow.down.right.and.arrow.up.left")
            }
        }
    }
}

#Preview("Light") {
    List {
        VideoRow(item: MediaItem(id: "video-0", creationDate: .now, kind: .video, duration: 95, size: ItemSize(bytes: 420_000_000)), isSelected: true, toggle: {}, play: {})
    }
    .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    List {
        VideoRow(item: MediaItem(id: "video-1", creationDate: .now, kind: .video, duration: 48, size: ItemSize(bytes: 140_000_000)), isSelected: false, toggle: {}, play: {})
    }
    .tint(SbuTheme.accentClean)
    .preferredColorScheme(.dark)
}
