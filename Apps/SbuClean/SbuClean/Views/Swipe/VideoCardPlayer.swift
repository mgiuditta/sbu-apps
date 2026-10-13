import AVKit
import SbuKit
import SwiftUI

/// A video that plays inside its card, with the system controls, before you decide.
///
/// A video kept only in iCloud is not downloaded: the card shows its frame and says so.
struct VideoCardPlayer: View {
    let item: MediaItem

    @Environment(\.photoLibrary) private var library
    @State private var player: AVPlayer?
    @State private var isUnavailable = false

    var body: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
            } else {
                MediaThumbnail(id: item.id, side: 1200, contentMode: .fit)
                if isUnavailable {
                    Label("Solo in iCloud: Sbu Clean non scarica i video", systemImage: "icloud")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.ink)
                        .padding(SbuTheme.space2)
                        .background(SbuTheme.surface, in: .rect(cornerRadius: SbuTheme.radiusSm))
                        .padding(SbuTheme.space3)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .task(id: item.id) {
            await load()
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func load() async {
        if let url = await library.videoURL(for: item.id) {
            player = AVPlayer(url: url)
        } else {
            isUnavailable = true
        }
    }
}

#Preview("Light") {
    VideoCardPlayer(item: MediaItem(id: "video-0", kind: .video))
        .padding()
}

#Preview("Dark") {
    VideoCardPlayer(item: MediaItem(id: "video-0", kind: .video))
        .padding()
        .preferredColorScheme(.dark)
}
