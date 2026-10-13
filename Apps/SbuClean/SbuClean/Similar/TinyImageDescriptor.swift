import Accelerate
import CoreGraphics

/// A stand-in for the Vision feature print where Vision cannot run (the simulator): the
/// picture shrunk to 32 × 24 grey pixels, centred and scaled to length one.
///
/// Copies land close together and different pictures far apart, as with Vision, so the
/// screens can be tried in the simulator; the thresholds are tuned for Vision, not for this.
nonisolated enum TinyImageDescriptor {
    static let width = 32
    static let height = 24

    static func describe(_ image: CGImage) -> [Float] {
        guard let pixels = ImageAnalyzer.grey(image, width: width, height: height) else { return [] }

        return normalized(pixels.map(Float.init))
    }

    /// The values minus their mean, divided by their length.
    static func normalized(_ values: [Float]) -> [Float] {
        guard !values.isEmpty else { return [] }

        let mean = vDSP.mean(values)
        let centred = vDSP.add(-mean, values)
        let length = vDSP.sumOfSquares(centred).squareRoot()
        return length > 0 ? vDSP.divide(centred, length) : centred
    }
}
