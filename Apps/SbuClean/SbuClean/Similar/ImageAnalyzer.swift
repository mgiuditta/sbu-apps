import CoreGraphics
import Vision

/// Runs Vision on one picture, on the device: feature print, face quality and sharpness.
nonisolated enum ImageAnalyzer {
    /// The side of the grey copy the sharpness is measured on: the same for every photo, so
    /// scores compare.
    static let sharpnessSide = 256

    /// Analyzes a picture; `nil` when Vision gives no feature print.
    static func analyze(_ image: CGImage) -> ImageAnalysis? {
        #if targetEnvironment(simulator)
        // The simulator cannot run Vision's networks (no Neural Engine, no Metal context): every
        // print comes out the same. A tiny grey copy stands in, so grouping can be tried there.
        return ImageAnalysis(featurePrint: TinyImageDescriptor.describe(image), sharpness: sharpness(of: image))
        #else
        return visionAnalysis(of: image)
        #endif
    }

    /// Feature print and face quality from Vision, sharpness from the picture.
    static func visionAnalysis(of image: CGImage) -> ImageAnalysis? {
        let printRequest = VNGenerateImageFeaturePrintRequest()
        printRequest.revision = VNGenerateImageFeaturePrintRequestRevision2
        printRequest.imageCropAndScaleOption = .scaleFill
        let faceRequest = VNDetectFaceCaptureQualityRequest()

        let handler = VNImageRequestHandler(cgImage: image)
        do {
            try handler.perform([printRequest, faceRequest])
        } catch {
            return nil
        }
        guard let observation = printRequest.results?.first, observation.elementType == .float else { return nil }

        let featurePrint: [Float] = observation.data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
        let faceQuality = faceRequest.results?.compactMap(\.faceCaptureQuality).max()
        return ImageAnalysis(featurePrint: featurePrint, faceQuality: faceQuality, sharpness: sharpness(of: image))
    }

    /// The sharpness of a picture scaled to `sharpnessSide` on its longer side, in grey.
    static func sharpness(of image: CGImage) -> Float {
        let scale = Double(sharpnessSide) / Double(max(image.width, image.height, 1))
        let width = max(Int(Double(image.width) * scale), 3)
        let height = max(Int(Double(image.height) * scale), 3)
        guard let pixels = grey(image, width: width, height: height) else { return 0 }

        return Sharpness.laplacianVariance(of: pixels, width: width, height: height)
    }

    /// The picture scaled to `width` × `height` in 8-bit grey, row by row.
    static func grey(_ image: CGImage, width: Int, height: Int) -> [UInt8]? {
        var pixels = [UInt8](repeating: 0, count: width * height)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGImageAlphaInfo.none.rawValue
            ) else { return false }

            context.interpolationQuality = .medium
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        return drawn ? pixels : nil
    }
}
