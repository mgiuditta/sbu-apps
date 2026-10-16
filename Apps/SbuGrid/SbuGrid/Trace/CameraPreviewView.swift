import AVFoundation
import UIKit

/// A view whose layer is a camera preview.
final class CameraPreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    // ponytail: the cast cannot fail, `layerClass` makes the layer.
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
