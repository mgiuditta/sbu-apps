import Foundation
import Vision

/// Finds the codes in a photo, on the iPhone, with Vision.
nonisolated enum PhotoCodeReader {
    /// Every code in the image, without duplicates, in Vision's order.
    @concurrent
    static func codes(in imageData: Data) async throws -> [CodeReading] {
        let request = VNDetectBarcodesRequest()
        request.symbologies = Symbology.allCases.map(\.visionSymbology)
        try VNImageRequestHandler(data: imageData).perform([request])
        var seen = Set<CodeReading>()
        return (request.results ?? []).compactMap { observation in
            guard let raw = observation.payloadStringValue, let symbology = Symbology(visionSymbology: observation.symbology) else { return nil }
            let reading = CodeReading(raw: raw, symbology: symbology)
            return seen.insert(reading).inserted ? reading : nil
        }
    }
}
