import SbuKit
import SwiftUI

/// The item's photos full screen, whole, on paper; swipe between them.
struct PhotoViewer: View {
    let photos: [ItemPhoto]
    @Binding var selection: Int

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                ForEach(Array(photos.enumerated()), id: \.element.uuid) { index, photo in
                    PhotoView(photo: photo, maxPixelSize: PhotoProcessor.maxPixelSize, contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityElement()
                        .accessibilityLabel(Text("Foto \(index + 1) di \(photos.count)"))
                        .accessibilityAddTraits(.isImage)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .always : .never))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .background(SbuTheme.paper)
            .navigationTitle(Text("\(selection + 1) di \(photos.count)"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fine", action: close)
                }
            }
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    @Previewable @State var selection = 0
    PhotoViewer(photos: ItemPhoto.previewSamples(), selection: $selection)
}

#Preview("Dark") {
    @Previewable @State var selection = 1
    PhotoViewer(photos: ItemPhoto.previewSamples(), selection: $selection)
        .preferredColorScheme(.dark)
}
