/// How one video will be compressed with the current settings, and how big it will come out.
///
/// The estimate is what the screen shows before compressing; the encoder gets the same
/// numbers, so the real file lands close to it.
nonisolated struct CompressionPlan: Equatable, Sendable {
    /// The encoder does not go under this: below it the picture falls apart.
    static let minimumVideoBitsPerSecond = 100_000.0
    /// AAC stereo, as the camera records it.
    static let audioBitsPerSecond = 128_000.0
    /// The least AAC stereo at 44.1 kHz takes.
    static let minimumAudioBitsPerSecond = 64_000.0
    /// The container adds about this share on top of the streams.
    static let containerOverhead = 1.02
    /// And about this much in headers.
    static let containerHeaderBytes = 16_384.0

    let size: PixelSize
    /// Frames per second of the copy, never above the source.
    let frameRate: Double
    let videoBitsPerSecond: Double
    /// 0 without audio, or when the settings remove it.
    let audioBitsPerSecond: Double
    let codec: VideoCodec
    let format: OutputFormat
    /// What the file should weigh, never more than the source.
    let estimatedBytes: Int64
    /// How the target in MB went, when there is one.
    let targetFit: TargetFit?

    init(source: SourceVideo, settings: CompressionSettings) {
        let size = source.size.scaled(toPercent: settings.dimensionPercent)
        let frameRate = min(Double(settings.frameRate), source.effectiveFrameRate)
        let audio = settings.removesAudio || !source.hasAudio ? 0 : Self.audioRate(for: source)
        let duration = source.isUsable ? source.duration : 0

        // What the source spends on this many pixels and frames: no point in spending more.
        let pixelShare = source.size.pixelCount > 0 ? Double(size.pixelCount) / Double(source.size.pixelCount) : 1
        let frameShare = frameRate / source.effectiveFrameRate
        let sourceShare = source.effectiveVideoBitsPerSecond * pixelShare * frameShare
        let clean = Double(size.pixelCount) * frameRate * settings.codec.cleanBitsPerPixel
        let ceiling = max(min(sourceShare > 0 ? sourceShare : clean, clean), Self.minimumVideoBitsPerSecond)

        var video: Double
        var fit: TargetFit?
        if let megabytes = settings.targetMegabytes, duration > 0 {
            let budget = (megabytes * 1_000_000 - Self.containerHeaderBytes) * 8 / duration / Self.containerOverhead
            let wanted = budget - audio
            if wanted < Self.minimumVideoBitsPerSecond {
                video = Self.minimumVideoBitsPerSecond
                fit = .tooSmall
            } else if wanted > ceiling {
                video = ceiling
                fit = .alreadySmaller
            } else {
                video = wanted
                fit = .fits
            }
        } else {
            let quality = Double(settings.qualityPercent.clamped(to: CompressionSettings.qualityRange)) / 100
            video = max(ceiling * quality, Self.minimumVideoBitsPerSecond)
        }
        video = video.rounded()

        let streams = (video + audio) * duration / 8 * Self.containerOverhead
        let estimate = duration > 0 ? Int64((streams + Self.containerHeaderBytes).rounded()) : 0

        self.size = size
        self.frameRate = frameRate
        self.videoBitsPerSecond = video
        self.audioBitsPerSecond = audio
        self.codec = settings.codec
        self.format = OutputFormat(sourceExtension: source.fileExtension, convertsToMP4: settings.convertsToMP4)
        self.estimatedBytes = min(estimate, max(source.bytes, 0))
        self.targetFit = fit
    }

    /// The share of the source the copy saves, 0 to 1.
    func savedFraction(of source: SourceVideo) -> Double {
        guard source.bytes > 0 else { return 0 }
        return max(0, 1 - Double(estimatedBytes) / Double(source.bytes))
    }

    /// The source's audio rate kept between what AAC stereo accepts and what the camera records.
    private static func audioRate(for source: SourceVideo) -> Double {
        let rate = source.audioBitsPerSecond
        guard rate.isFinite, rate > 0 else { return audioBitsPerSecond }
        return rate.clamped(to: minimumAudioBitsPerSecond...audioBitsPerSecond)
    }
}
