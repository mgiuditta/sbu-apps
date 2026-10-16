/// What the compressor needs to know about a video, read once from the file.
nonisolated struct SourceVideo: Equatable, Sendable {
    /// Length in seconds.
    var duration: Double
    /// Picture size as it plays, after the rotation the file asks for.
    var size: PixelSize
    /// Nominal frames per second; 0 when the file does not say.
    var frameRate: Double
    /// Average video bit rate; 0 when the file does not say.
    var videoBitsPerSecond: Double
    /// Average audio bit rate of all audio tracks; 0 without audio.
    var audioBitsPerSecond: Double
    var hasAudio: Bool
    /// Size on disk.
    var bytes: Int64
    /// The extension of the source file, such as "mov", to pick the output container.
    var fileExtension: String

    /// Whether the encoder can work on it: a picture, a length and a size, all real numbers.
    var isUsable: Bool {
        duration.isFinite && duration > 0 && size.width > 0 && size.height > 0 && bytes > 0
    }

    /// The frame rate to plan with: 30 when the file does not say or says something absurd.
    var effectiveFrameRate: Double {
        frameRate.isFinite && frameRate >= 1 && frameRate <= 1_000 ? frameRate : 30
    }

    /// The video bit rate to plan with: the file's own, or what is left of the file's size once
    /// the audio is taken out.
    var effectiveVideoBitsPerSecond: Double {
        if videoBitsPerSecond.isFinite, videoBitsPerSecond > 0 {
            return videoBitsPerSecond
        }
        guard isUsable else { return 0 }
        let audio = audioBitsPerSecond.isFinite ? max(audioBitsPerSecond, 0) : 0
        return max(Double(bytes) * 8 / duration - audio, 0)
    }
}
