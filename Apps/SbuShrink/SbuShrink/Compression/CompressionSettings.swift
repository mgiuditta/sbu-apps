/// What the user sets before compressing: the original app's two sliders (frame rate and
/// dimensions), the competitor's quality, and the "Avanzate" options the original lacks.
///
/// Every value is clamped to its range on the way in, so a stored or absurd value never
/// reaches the encoder.
nonisolated struct CompressionSettings: Codable, Equatable, Sendable {
    static let frameRateRange = 10...60
    static let dimensionRange = 10...100
    static let qualityRange = 10...100
    /// From 1 MB to 10 GB: a target outside it is a typo.
    static let targetMegabytesRange = 1.0...10_000.0

    /// The original suggests 24 and "not going under 24".
    static let suggestedFrameRate = 24
    /// The original suggests 80%.
    static let suggestedDimension = 80
    /// The competitor suggests 60%.
    static let suggestedQuality = 60

    /// Frames per second of the copy, never above the source's.
    var frameRate: Int {
        didSet { frameRate = frameRate.clamped(to: Self.frameRateRange) }
    }

    /// Side of the copy as a percentage of the source's.
    var dimensionPercent: Int {
        didSet { dimensionPercent = dimensionPercent.clamped(to: Self.dimensionRange) }
    }

    /// Share of the clean bit rate the encoder gets.
    var qualityPercent: Int {
        didSet { qualityPercent = qualityPercent.clamped(to: Self.qualityRange) }
    }

    /// Size to aim each video at, in MB (10^6 bytes); `nil` uses quality instead.
    var targetMegabytes: Double? {
        didSet { targetMegabytes = Self.clampedTarget(targetMegabytes) }
    }

    var codec: VideoCodec
    var removesAudio: Bool
    var convertsToMP4: Bool

    init(
        frameRate: Int = suggestedFrameRate,
        dimensionPercent: Int = suggestedDimension,
        qualityPercent: Int = suggestedQuality,
        targetMegabytes: Double? = nil,
        codec: VideoCodec = .h264,
        removesAudio: Bool = false,
        convertsToMP4: Bool = false
    ) {
        self.frameRate = frameRate.clamped(to: Self.frameRateRange)
        self.dimensionPercent = dimensionPercent.clamped(to: Self.dimensionRange)
        self.qualityPercent = qualityPercent.clamped(to: Self.qualityRange)
        self.targetMegabytes = Self.clampedTarget(targetMegabytes)
        self.codec = codec
        self.removesAudio = removesAudio
        self.convertsToMP4 = convertsToMP4
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = CompressionSettings()
        self.init(
            frameRate: (try? container.decode(Int.self, forKey: .frameRate)) ?? defaults.frameRate,
            dimensionPercent: (try? container.decode(Int.self, forKey: .dimensionPercent)) ?? defaults.dimensionPercent,
            qualityPercent: (try? container.decode(Int.self, forKey: .qualityPercent)) ?? defaults.qualityPercent,
            targetMegabytes: try? container.decodeIfPresent(Double.self, forKey: .targetMegabytes),
            codec: (try? container.decode(VideoCodec.self, forKey: .codec)) ?? defaults.codec,
            removesAudio: (try? container.decode(Bool.self, forKey: .removesAudio)) ?? defaults.removesAudio,
            convertsToMP4: (try? container.decode(Bool.self, forKey: .convertsToMP4)) ?? defaults.convertsToMP4
        )
    }

    /// Whether any "Avanzate" option differs from its default.
    var hasAdvancedChanges: Bool {
        targetMegabytes != nil || codec != .h264 || removesAudio || convertsToMP4
    }

    private static func clampedTarget(_ value: Double?) -> Double? {
        guard let value, value.isFinite else { return nil }
        return min(max(value, targetMegabytesRange.lowerBound), targetMegabytesRange.upperBound)
    }
}
