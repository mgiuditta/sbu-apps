import SbuKit
import SwiftUI

/// A video in the list: its frame (tap to play), then the checkbox with size, length and date.
/// Swipe or long press for Comprimi.
struct VideoRow: View {
    let item: MediaItem
    @Binding var isSelected: Bool
    let play: () -> Void

    @ScaledMetric(relativeTo: .body) private var thumbnailSide: CGFloat = 64

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
                            .background(SbuTheme.paper, in: .rect(cornerRadius: SbuTheme.radiusSm))
                    }
                    .clipShape(.rect(cornerRadius: SbuTheme.radiusSm))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Riproduci")
            .accessibilityIdentifier("video.play")

            Toggle(isOn: $isSelected) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.bytes.sizeText)
                        .font(SbuTheme.statSmall)
                        .foregroundStyle(SbuTheme.ink)
                    Text("\(item.durationText) · \(item.creationDate?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
            .toggleStyle(SbuCheckboxStyle())
            .sbuAffectsFigure(isSelected)
            .accessibilityLabel(item.spokenDescription)
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
        VideoRow(item: MediaItem(id: "video-0", creationDate: .now, kind: .video, duration: 95, size: ItemSize(bytes: 420_000_000)), isSelected: .constant(true), play: {})
    }
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    List {
        VideoRow(item: MediaItem(id: "video-1", creationDate: .now, kind: .video, duration: 48, size: ItemSize(bytes: 140_000_000)), isSelected: .constant(false), play: {})
    }
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
