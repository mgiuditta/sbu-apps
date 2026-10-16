import AVFoundation

/// The codec the compressed copy is written with.
nonisolated enum VideoCodec: String, CaseIterable, Codable, Identifiable, Sendable {
    /// Plays everywhere: the default, like the original app's output.
    case h264
    /// About a third smaller at the same quality; every iPhone that runs iOS 17 encodes it in hardware.
    case hevc

    var id: Self { self }

    var avCodec: AVVideoCodecType {
        switch self {
        case .h264: .h264
        case .hevc: .hevc
        }
    }

    /// Bits per pixel per frame that keep a re-encode visually clean at 100% quality.
    ///
    /// The ceiling of the bit rate: phone cameras record far above it, which is where the
    /// space comes from. HEVC needs about two thirds of H.264 for the same picture.
    var cleanBitsPerPixel: Double {
        switch self {
        case .h264: 0.15
        case .hevc: 0.10
        }
    }
}
