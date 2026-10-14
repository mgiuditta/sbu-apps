import SbuKit
import SwiftUI

/// The camera in a frame on paper: the picture, or what to do without one. Pinch to zoom.
struct CameraFrame: View {
    let model: ScannerModel
    @State private var zoomAtPinchStart: CGFloat?

    var body: some View {
        ZStack {
            SbuTheme.surfaceSunken
            switch model.state {
            case .running:
                CameraPreview(session: model.session)
                    .gesture(pinch)
                    .accessibilityElement()
                    .accessibilityLabel("Fotocamera")
                    .accessibilityHint("Inquadra un codice: si legge da solo.")
                    .accessibilityValue(Text("Zoom \(Double(model.zoom).formatted(.number.precision(.fractionLength(0...1))))×"))
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: model.setZoom(model.zoom + 1)
                        case .decrement: model.setZoom(model.zoom - 1)
                        @unknown default: break
                        }
                    }
            case .unavailable where model.isDemo:
                DemoCamera(read: model.readDemoCode)
            case .denied, .unavailable:
                CameraMessage(state: model.state)
            case .idle:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(.rect(cornerRadius: SbuTheme.radiusLg))
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusLg)
                .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline)
        }
    }

    private var pinch: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let start = zoomAtPinchStart ?? model.zoom
                zoomAtPinchStart = start
                model.setZoom(start * value.magnification)
            }
            .onEnded { _ in zoomAtPinchStart = nil }
    }
}

#Preview("Light") {
    CameraFrame(model: ScannerModel(isDemo: true))
        .padding()
}

#Preview("Dark") {
    CameraFrame(model: ScannerModel(isDemo: true))
        .padding()
        .preferredColorScheme(.dark)
}
