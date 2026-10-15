import SbuKit
import SwiftUI

/// The item's photos, one per page; a tap opens the one on screen full size.
struct PhotoCarousel: View {
    let photos: [ItemPhoto]

    @State private var selection = 0
    @State private var isShowingViewer = false
    @ScaledMetric(relativeTo: .body) private var height: CGFloat = 280

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(photos.enumerated()), id: \.element.uuid) { index, photo in
                Button {
                    isShowingViewer = true
                } label: {
                    PhotoView(photo: photo, maxPixelSize: 1200)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Foto \(index + 1) di \(photos.count)"))
                .accessibilityHint(Text("Apre la foto a schermo intero"))
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .always : .never))
        .frame(height: min(height, 420))
        .clipShape(.rect(cornerRadius: SbuTheme.radiusLg))
        .fullScreenCover(isPresented: $isShowingViewer) {
            PhotoViewer(photos: photos, selection: $selection)
        }
    }
}

#Preview("Light") {
    PhotoCarousel(photos: ItemPhoto.previewSamples())
        .padding(SbuTheme.space4)
}

#Preview("Dark") {
    PhotoCarousel(photos: ItemPhoto.previewSamples())
        .padding(SbuTheme.space4)
        .preferredColorScheme(.dark)
}
