import SbuKit
import SwiftUI

/// The crop, as in DrawinGrid: the whole photo with a frame to move and handles at its corners,
/// the size under it, Annulla or Ritaglia.
///
/// The photo sits a margin inside the safe area, so every handle is within reach, the bottom
/// ones too on an iPhone SE, where DrawinGrid's bottom handle cannot be reached.
struct CropView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: GridModel

    @State private var rect: CGRect

    init(model: GridModel) {
        self.model = model
        _rect = State(initialValue: model.crop ?? CropGeometry.fitted(aspect: model.paper.aspectRatio, imageSize: model.photoSize))
    }

    private var aspect: Double? {
        model.paper.aspectRatio
    }

    private var pixelSize: CGSize {
        CropGeometry.pixelRect(rect, imageSize: model.photoSize).size
    }

    private var sizeText: String {
        let pixels = String(localized: "\(Int(pixelSize.width)) × \(Int(pixelSize.height)) pixel", comment: "Size of the crop in pixels.")
        guard let size = model.paper.size else { return pixels }
        return "\(LengthFormat.sheet(width: size.width, height: size.height, unit: model.paper.unit)) · \(pixels)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: SbuTheme.space4) {
                if let photo = model.photo {
                    GeometryReader { proxy in
                        let fitted = AspectFit.size(of: model.photoSize, in: proxy.size)
                        ZStack {
                            Image(decorative: photo, scale: 1)
                                .resizable()
                                .interpolation(.high)
                            CropFrame(rect: $rect, aspect: aspect, imageSize: model.photoSize, sizeText: sizeText)
                        }
                        .frame(width: fitted.width, height: fitted.height)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                    // Room for the handles' reach beyond the photo's edges.
                    .padding(SbuTheme.space6)
                }

                Text(verbatim: sizeText)
                    .font(SbuTheme.footnote)
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.inkMuted)
                    .padding(.bottom, SbuTheme.space4)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SbuTheme.paper)
            .navigationTitle("Ritaglio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ritaglia", action: apply)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Ripristina", action: reset)
                        .tint(SbuTheme.ink)
                }
            }
        }
    }

    private func cancel() {
        dismiss()
    }

    private func apply() {
        model.setCrop(rect)
        dismiss()
    }

    /// Back to the largest crop of the sheet's shape, or the whole photo without a sheet.
    private func reset() {
        withAnimation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion)) {
            rect = CropGeometry.fitted(aspect: aspect, imageSize: model.photoSize)
        }
    }
}

#Preview("Light") {
    CropView(model: .forLaunch(.demo))
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    CropView(model: .forLaunch(.demo))
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
