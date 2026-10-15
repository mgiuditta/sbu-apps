import SbuKit
import SwiftUI

/// One kept photo, decoded away from the main thread at the size the screen needs.
struct PhotoView: View {
    let photo: ItemPhoto
    let maxPixelSize: Int
    var contentMode = ContentMode.fill

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                SbuTheme.surfaceSunken
            }
        }
        .task(id: photo.uuid) {
            guard let data = photo.data else { return }
            image = await Self.decode(data, maxPixelSize: maxPixelSize)
        }
    }

    @concurrent
    private nonisolated static func decode(_ data: Data, maxPixelSize: Int) async -> UIImage? {
        PhotoProcessor.image(data, maxPixelSize: maxPixelSize)
    }
}

#Preview("Light") {
    PhotoView(photo: ItemPhoto.previewSamples(1)[0], maxPixelSize: 600)
        .frame(width: 300, height: 200)
}

#Preview("Dark") {
    PhotoView(photo: ItemPhoto.previewSamples(1)[0], maxPixelSize: 600, contentMode: .fit)
        .frame(width: 300, height: 200)
        .preferredColorScheme(.dark)
}
