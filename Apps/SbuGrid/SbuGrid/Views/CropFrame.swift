import SbuKit
import SwiftUI

/// The crop over the photo: paper veils what is left out, the frame moves with a drag inside
/// it, and the four corner handles resize it, held to the sheet's shape.
///
/// The frame and the handles are paper with an ink edge, so they show on any photo. VoiceOver
/// gets one element, with actions to enlarge, shrink and move it.
struct CropFrame: View {
    /// The side of a handle's visible square and of its touch area.
    private static let handleSide = SbuTheme.controlRoundXs
    private static let touchSide = SbuTheme.controlRoundSm
    /// How far one VoiceOver action moves or resizes the crop.
    private static let accessibilityStep: CGFloat = 0.05

    @Binding var rect: CGRect
    let aspect: Double?
    let imageSize: CGSize
    let sizeText: String

    /// The crop when the current drag began.
    @State private var dragStart: CGRect?

    var body: some View {
        GeometryReader { proxy in
            let frame = displayed(rect, in: proxy.size)
            ZStack(alignment: .topLeading) {
                Path { path in
                    path.addRect(CGRect(origin: .zero, size: proxy.size))
                    path.addRect(frame)
                }
                .fill(SbuTheme.surface.opacity(0.6), style: FillStyle(eoFill: true))
                .allowsHitTesting(false)

                Rectangle()
                    .strokeBorder(SbuTheme.ink, lineWidth: SbuTheme.hairline * 3)
                    .overlay {
                        Rectangle().strokeBorder(SbuTheme.surface, lineWidth: SbuTheme.hairline)
                    }
                    .contentShape(.rect)
                    .frame(width: frame.width, height: frame.height)
                    .offset(x: frame.minX, y: frame.minY)
                    .gesture(move(in: proxy.size))

                ForEach(CropCorner.allCases, id: \.self) { corner in
                    let point = corner.point(in: frame)
                    handle
                        .frame(width: Self.touchSide, height: Self.touchSide)
                        .contentShape(.rect)
                        .offset(x: point.x - Self.touchSide / 2, y: point.y - Self.touchSide / 2)
                        .gesture(resize(corner, in: proxy.size))
                }
            }
            .environment(\.colorScheme, .light)
            .accessibilityElement()
            .accessibilityLabel(Text("Ritaglio"))
            .accessibilityValue(Text(verbatim: sizeText))
            .accessibilityActions {
                Button("Allarga") { scale(by: 1 + Self.accessibilityStep) }
                Button("Restringi") { scale(by: 1 - Self.accessibilityStep) }
                Button("Sposta a sinistra") { move(by: CGSize(width: -Self.accessibilityStep, height: 0)) }
                Button("Sposta a destra") { move(by: CGSize(width: Self.accessibilityStep, height: 0)) }
                Button("Sposta in alto") { move(by: CGSize(width: 0, height: -Self.accessibilityStep)) }
                Button("Sposta in basso") { move(by: CGSize(width: 0, height: Self.accessibilityStep)) }
            }
        }
    }

    private var handle: some View {
        Rectangle()
            .fill(SbuTheme.surface)
            .strokeBorder(SbuTheme.ink, lineWidth: SbuTheme.hairline * 2)
            .frame(width: Self.handleSide, height: Self.handleSide)
    }

    private func displayed(_ rect: CGRect, in size: CGSize) -> CGRect {
        CGRect(x: rect.minX * size.width, y: rect.minY * size.height, width: rect.width * size.width, height: rect.height * size.height)
    }

    private func move(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let start = dragStart ?? rect
                dragStart = start
                rect = CropGeometry.moved(start, by: CGSize(width: value.translation.width / size.width, height: value.translation.height / size.height))
            }
            .onEnded { _ in
                dragStart = nil
            }
    }

    private func resize(_ corner: CropCorner, in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let start = dragStart ?? rect
                dragStart = start
                // From where the corner was, moved as far as the finger: the finger need not
                // land exactly on the corner.
                let corner0 = corner.point(in: start)
                let point = CGPoint(
                    x: corner0.x + value.translation.width / size.width,
                    y: corner0.y + value.translation.height / size.height
                )
                rect = CropGeometry.dragged(start, corner: corner, to: point, aspect: aspect, imageSize: imageSize)
            }
            .onEnded { _ in
                dragStart = nil
            }
    }

    private func scale(by factor: CGFloat) {
        rect = CropGeometry.scaled(rect, by: factor, aspect: aspect, imageSize: imageSize)
    }

    private func move(by delta: CGSize) {
        rect = CropGeometry.moved(rect, by: delta)
    }
}

#Preview("Light") {
    @Previewable @State var rect = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.6)
    CropFrame(rect: $rect, aspect: nil, imageSize: DemoPhoto.size, sizeText: "960 × 960 pixel")
        .frame(width: 300, height: 400)
        .background(SbuTheme.inkMuted)
}

#Preview("Dark") {
    @Previewable @State var rect = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.6)
    CropFrame(rect: $rect, aspect: nil, imageSize: DemoPhoto.size, sizeText: "960 × 960 pixel")
        .frame(width: 300, height: 400)
        .background(SbuTheme.inkMuted)
        .preferredColorScheme(.dark)
}
