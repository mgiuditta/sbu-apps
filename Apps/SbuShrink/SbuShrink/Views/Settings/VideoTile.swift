import SbuKit
import SwiftUI

/// A picked video in the strip: its first frame and its weight under it.
struct VideoTile: View {
    let job: VideoJob

    @ScaledMetric(relativeTo: .body) private var side: CGFloat = 64

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            VideoThumbnail(file: job.file)
                .frame(width: side, height: side)
                .clipShape(.rect(cornerRadius: SbuTheme.radiusMd))
                .overlay {
                    if job.state == .loading {
                        ProgressView()
                    }
                }

            Text(Int64(job.source?.bytes ?? 0), format: SizeFormat())
                .font(SbuTheme.footnote)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
                .opacity(job.source == nil ? 0 : 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(job.name.isEmpty ? Text("Video in lettura") : Text(verbatim: job.spokenName))
        .accessibilityValue(job.source.map { Text($0.bytes, format: .size) } ?? Text(verbatim: ""))
    }
}

#Preview("Light") {
    HStack {
        VideoTile(job: VideoJob(assetID: nil, name: "IMG_1669.MOV", source: DemoVideos.sources["IMG_1669.MOV"], state: .waiting))
        VideoTile(job: VideoJob(assetID: nil))
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    HStack {
        VideoTile(job: VideoJob(assetID: nil, name: "IMG_1669.MOV", source: DemoVideos.sources["IMG_1669.MOV"], state: .waiting))
        VideoTile(job: VideoJob(assetID: nil))
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
    .preferredColorScheme(.dark)
}
