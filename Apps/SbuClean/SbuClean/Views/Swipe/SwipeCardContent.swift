import SbuKit
import SwiftUI

/// The picture on a card: the whole photo, or the video ready to play.
struct SwipeCardContent: View {
    let item: MediaItem
    var playsVideo = false

    /// Cards load a large picture: the screen's width at full resolution.
    private static let pictureSide: CGFloat = 1200

    var body: some View {
        Group {
            if item.kind == .video && playsVideo {
                VideoCardPlayer(item: item)
            } else {
                MediaThumbnail(id: item.id, side: Self.pictureSide, contentMode: .fit)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SbuTheme.surfaceSunken)
        .clipShape(.rect(cornerRadius: SbuTheme.radiusCard))
    }
}

#Preview("Light") {
    SwipeCardContent(item: MediaItem(id: "photo-1", kind: .photo))
        .padding()
}

#Preview("Dark") {
    SwipeCardContent(item: MediaItem(id: "photo-1", kind: .photo))
        .padding()
        .preferredColorScheme(.dark)
}
