import SbuKit
import SwiftUI

/// A picture fitted in the space it has, that pinches to zoom up to 8 times, drags when zoomed
/// and returns to whole with a double tap, as in DrawinGrid's full screen. VoiceOver zooms with
/// its own gesture, through the zoom action.
struct ZoomablePicture<Content: View>: View {
    /// The shape of the picture, such as its size in pixels.
    let aspect: CGSize
    let label: LocalizedStringResource
    let value: String
    @ViewBuilder let content: Content

    @State private var zoom = ZoomState.identity
    /// The zoom while a gesture runs; `nil` between gestures.
    @State private var liveZoom: ZoomState?
    /// How far the current drag had gone at its last change.
    @State private var lastTranslation = CGSize.zero

    private var shownZoom: ZoomState {
        liveZoom ?? zoom
    }

    var body: some View {
        GeometryReader { proxy in
            let fitted = AspectFit.size(of: aspect, in: proxy.size)
            content
                .frame(width: fitted.width, height: fitted.height)
                .scaleEffect(shownZoom.scale)
                .offset(shownZoom.offset)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .contentShape(.rect)
                .clipped()
                .gesture(magnify(in: fitted).simultaneously(with: pan(in: fitted)))
                .onTapGesture(count: 2) {
                    toggleZoom(in: fitted)
                }
                .accessibilityElement()
                .accessibilityLabel(Text(label))
                .accessibilityValue(Text(verbatim: value))
                .accessibilityAddTraits(.isImage)
                .accessibilityZoomAction { action in
                    zoom = zoom.zoomed(by: action.direction == .zoomIn ? ZoomState.step : 1 / ZoomState.step, in: fitted)
                }
        }
    }

    private func magnify(in size: CGSize) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                liveZoom = zoom.zoomed(by: value.magnification, in: size)
            }
            .onEnded { _ in
                commit()
            }
    }

    private func pan(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                // Pinching moves the live zoom too: pan from it, not from the committed one.
                let base = liveZoom ?? zoom
                liveZoom = base.panned(by: value.translation - lastTranslation, in: size)
                lastTranslation = value.translation
            }
            .onEnded { _ in
                lastTranslation = .zero
                commit()
            }
    }

    private func commit() {
        if let liveZoom {
            zoom = liveZoom
        }
        liveZoom = nil
    }

    private func toggleZoom(in size: CGSize) {
        withAnimation(.snappy) {
            zoom = zoom.isZoomed ? .identity : zoom.zoomed(by: ZoomState.step, in: size)
        }
    }
}

private extension CGSize {
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
}

#Preview("Light") {
    ZoomablePicture(aspect: DemoPhoto.size, label: "Foto con la griglia", value: "4 × 6") {
        GridPicture(image: DemoPhoto.stillLife(), settings: GridSettings(), rule: GridSettings().cellRule)
    }
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    ZoomablePicture(aspect: DemoPhoto.size, label: "Foto con la griglia", value: "4 × 6") {
        GridPicture(image: DemoPhoto.stillLife(), settings: GridSettings(), rule: GridSettings().cellRule)
    }
    .background(SbuTheme.surface)
    .preferredColorScheme(.dark)
}
