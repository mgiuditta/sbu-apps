import SbuKit
import SwiftUI

/// A video played full screen before deciding.
struct VideoPreviewSheet: View {
    let item: MediaItem

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VideoCardPlayer(item: item)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(SbuTheme.surface)
                .navigationTitle(Text(item.bytes.formatted(.byteCount(style: .file))))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fine") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview("Light") {
    VideoPreviewSheet(item: MediaItem(id: "video-0", kind: .video, size: ItemSize(bytes: 420_000_000)))
}

#Preview("Dark") {
    VideoPreviewSheet(item: MediaItem(id: "video-0", kind: .video, size: ItemSize(bytes: 420_000_000)))
        .preferredColorScheme(.dark)
}
