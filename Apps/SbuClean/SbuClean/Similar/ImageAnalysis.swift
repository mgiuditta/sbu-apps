import Foundation

/// What Vision says about one photo: enough to group it and to pick the best of a group.
nonisolated struct ImageAnalysis: Codable, Equatable, Sendable {
    /// The Vision feature print (revision 2): 768 numbers, close for pictures that look alike.
    var featurePrint: [Float]
    /// The best face capture quality in the picture, 0 to 1; `nil` without faces.
    var faceQuality: Float?
    /// The variance of the Laplacian of a small grey copy: higher is sharper.
    var sharpness: Float

    private enum CodingKeys: String, CodingKey {
        case featurePrint
        case faceQuality
        case sharpness
    }

    init(featurePrint: [Float], faceQuality: Float? = nil, sharpness: Float = 0) {
        self.featurePrint = featurePrint
        self.faceQuality = faceQuality
        self.sharpness = sharpness
    }

    // The print is stored as raw bytes: a cache of thousands of photos stays small and fast.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .featurePrint)
        featurePrint = data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
        faceQuality = try container.decodeIfPresent(Float.self, forKey: .faceQuality)
        sharpness = try container.decode(Float.self, forKey: .sharpness)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = featurePrint.withUnsafeBufferPointer { Data(buffer: $0) }
        try container.encode(data, forKey: .featurePrint)
        try container.encodeIfPresent(faceQuality, forKey: .faceQuality)
        try container.encode(sharpness, forKey: .sharpness)
    }
}
