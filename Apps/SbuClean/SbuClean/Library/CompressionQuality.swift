import AVFoundation

/// The three qualities the video compressor offers, low to high.
nonisolated enum CompressionQuality: String, CaseIterable, Identifiable, Sendable {
    case low
    case medium
    case high

    var id: Self { self }

    /// The `AVAssetExportSession` preset that makes it.
    var exportPreset: String {
        switch self {
        case .low: AVAssetExportPreset960x540
        case .medium: AVAssetExportPreset1280x720
        case .high: AVAssetExportPreset1920x1080
        }
    }

    /// The target bit rate in bits per second, video and audio together, for the estimate.
    ///
    /// Close to what the export presets produce with H.264: the real file lands within a few
    /// percent, so the screen says "about".
    var bitsPerSecond: Double {
        switch self {
        case .low: 2_000_000
        case .medium: 5_000_000
        case .high: 10_000_000
        }
    }

    /// The estimated size of a video of `duration` seconds, never above the original's.
    func estimatedBytes(duration: TimeInterval, originalBytes: Int64) -> Int64 {
        let estimate = Int64(bitsPerSecond / 8 * max(duration, 0))
        return min(estimate, originalBytes)
    }
}
