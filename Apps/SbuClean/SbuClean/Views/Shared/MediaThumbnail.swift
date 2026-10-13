import SbuKit
import SwiftUI

/// A photo or video frame loaded from the library, filling its frame.
///
/// Decorative for VoiceOver: the control around it says what it is.
struct MediaThumbnail: View {
    @Environment(\.photoLibrary) private var library
    @Environment(\.displayScale) private var displayScale

    let id: String
    /// The side in points the picture is loaded for.
    var side: CGFloat = 120
    var contentMode: ContentMode = .fill

    @State private var image: UIImage?

    var body: some View {
        Rectangle()
            .fill(SbuTheme.surfaceSunken)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                }
            }
            .clipped()
            .accessibilityHidden(true)
            .task(id: id) {
                image = await library.image(for: id, pixelSide: side * displayScale)
            }
    }
}

#Preview("Light") {
    MediaThumbnail(id: "photo-0")
        .frame(width: 160, height: 160)
}

#Preview("Dark") {
    MediaThumbnail(id: "photo-0")
        .frame(width: 160, height: 160)
        .preferredColorScheme(.dark)
}
