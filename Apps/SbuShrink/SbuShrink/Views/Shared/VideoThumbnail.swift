import AVFoundation
import SbuKit
import SwiftUI

/// The first frame of a video file, upright; a film symbol on paper until it is ready or when
/// there is no picture.
struct VideoThumbnail: View {
    let file: URL?

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            SbuTheme.surfaceSunken
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "film")
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .accessibilityHidden(true)
        .task(id: file) {
            image = await Self.firstFrame(of: file)
        }
    }

    @concurrent
    private static func firstFrame(of file: URL?) async -> UIImage? {
        guard let file, FileManager.default.fileExists(atPath: file.path()) else { return nil }
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: file))
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 240, height: 240)
        guard let (frame, _) = try? await generator.image(at: .zero) else { return nil }
        return UIImage(cgImage: frame)
    }
}

#Preview("Light") {
    VideoThumbnail(file: nil)
        .frame(width: 64, height: 64)
}

#Preview("Dark") {
    VideoThumbnail(file: nil)
        .frame(width: 64, height: 64)
        .preferredColorScheme(.dark)
}
