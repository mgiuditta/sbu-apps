import AVFoundation
import SbuKit
import SwiftUI

/// The camera with the see-through photo and the grid over it; under them, how much of the
/// photo shows and the lock that keeps a stray touch from moving it.
struct TraceStage: View {
    @Bindable var model: GridModel
    let session: AVCaptureSession
    @Binding var isLocked: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(session: session)
                .ignoresSafeArea()

            if let picture = model.picture {
                ZoomablePicture(aspect: model.pictureSize, label: "Foto con la griglia", value: model.count.spoken) {
                    GridPicture(image: picture, settings: model.settings, rule: model.cellRule, photoOpacity: model.trace.photoOpacity)
                }
                .allowsHitTesting(isLocked == false)
                .padding(.bottom, SbuTheme.controlRoundLg * 2)
            }

            TraceControls(opacity: $model.trace.photoOpacity, isLocked: $isLocked)
        }
    }
}

#Preview("Light") {
    @Previewable @State var isLocked = false
    TraceStage(model: .forLaunch(.demo), session: AVCaptureSession(), isLocked: $isLocked)
        .tint(SbuTheme.ink)
}

#Preview("Dark") {
    @Previewable @State var isLocked = true
    TraceStage(model: .forLaunch(.demo), session: AVCaptureSession(), isLocked: $isLocked)
        .tint(SbuTheme.ink)
        .preferredColorScheme(.dark)
}
