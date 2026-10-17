import AVKit
import SbuKit
import SwiftUI

/// A video that plays inside its card, with the system controls, before you decide.
///
/// A video kept only in iCloud shows its frame and downloads only when you ask, with its
/// progress and a way to stop.
struct VideoCardPlayer: View {
    private enum Phase: Equatable {
        case loading
        case inCloud
        case downloading
        case failed
        case ready
    }

    let item: MediaItem

    @Environment(\.photoLibrary) private var library
    @State private var phase = Phase.loading
    @State private var player: AVPlayer?
    @State private var progress = TransferProgress()
    @State private var download: Task<Void, Never>?

    var body: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
            } else {
                MediaThumbnail(id: item.id, side: 1200, contentMode: .fit)
                if phase != .loading {
                    CloudVideoPanel(
                        isDownloading: phase == .downloading,
                        failed: phase == .failed,
                        fraction: progress.fraction,
                        download: startDownload,
                        cancel: cancelDownload
                    )
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
            download?.cancel()
        }
    }

    private func load() async {
        if let url = await library.videoURL(for: item.id) {
            play(url)
        } else {
            phase = .inCloud
        }
    }

    private func play(_ url: URL) {
        player = AVPlayer(url: url)
        phase = .ready
    }

    private func startDownload() {
        progress.fraction = 0
        phase = .downloading
        let progress = progress
        download = Task {
            do {
                let url = try await library.downloadVideo(for: item.id, progress: progress.report)
                play(url)
            } catch is CancellationError {
                phase = .inCloud
            } catch {
                phase = Task.isCancelled ? .inCloud : .failed
            }
        }
    }

    private func cancelDownload() {
        download?.cancel()
        download = nil
        phase = .inCloud
    }
}

#Preview("Light") {
    VideoCardPlayer(item: MediaItem(id: "video-0", kind: .video))
        .padding()
        .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    VideoCardPlayer(item: MediaItem(id: "video-0", kind: .video))
        .padding()
        .environment(\.sbuAccent, .clean)
        .preferredColorScheme(.dark)
}
