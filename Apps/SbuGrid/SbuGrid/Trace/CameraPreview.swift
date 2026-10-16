import AVFoundation
import SwiftUI
import UIKit

/// The live picture of a capture session, filling its frame. SwiftUI has no camera view, so this
/// wraps a preview layer. Decorative: the paper under the photo.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        view.isAccessibilityElement = false
        return view
    }

    func updateUIView(_ view: CameraPreviewView, context: Context) {}
}
