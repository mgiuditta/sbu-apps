import Testing
@testable import SbuShrink

struct CompressionPlanTests {
    @Test func theSuggestedSettingsSaveAsMuchAsTheOriginalPromises() {
        // The original's samples save 81% to 89% with 24 fps and 80%.
        let source = SourceVideo.phone()
        let plan = CompressionPlan(source: source, settings: CompressionSettings())
        #expect(plan.size == PixelSize(width: 1536, height: 864))
        #expect(plan.frameRate == 24)
        #expect(plan.audioBitsPerSecond == 128_000)
        #expect(plan.codec == .h264)
        #expect(plan.format == .mov)
        #expect(plan.targetFit == nil)
        #expect((0.75...0.9).contains(plan.savedFraction(of: source)))
    }

    @Test func theEstimateIsTheStreamsTimesTheDurationPlusTheContainer() {
        let source = SourceVideo.phone()
        let plan = CompressionPlan(source: source, settings: CompressionSettings())
        let streams = (plan.videoBitsPerSecond + plan.audioBitsPerSecond) * source.duration / 8
        let expected = streams * CompressionPlan.containerOverhead + CompressionPlan.containerHeaderBytes
        #expect(abs(Double(plan.estimatedBytes) - expected) <= 1)
    }

    @Test(arguments: [(24.0, 60, 24.0), (30, 24, 24), (30, 60, 30), (29.97, 30, 29.97), (240, 60, 60), (0, 60, 30), (.nan, 24, 24)])
    func frameRateIsNeverAboveTheSource(sourceRate: Double, setting: Int, expected: Double) {
        let plan = CompressionPlan(source: .phone(frameRate: sourceRate), settings: CompressionSettings(frameRate: setting))
        #expect(plan.frameRate == expected)
    }

    @Test(arguments: [(10, 20), (20, 30), (30, 40), (40, 50), (50, 60), (60, 70), (70, 80), (80, 90), (90, 100)])
    func higherQualityNeverWeighsLess(lower: Int, higher: Int) {
        let source = SourceVideo.phone()
        let low = CompressionPlan(source: source, settings: CompressionSettings(qualityPercent: lower))
        let high = CompressionPlan(source: source, settings: CompressionSettings(qualityPercent: higher))
        #expect(low.estimatedBytes < high.estimatedBytes)
    }

    @Test(arguments: [(10, 30), (30, 50), (50, 70), (70, 90), (90, 100)])
    func largerDimensionsNeverWeighLess(lower: Int, higher: Int) {
        let source = SourceVideo.phone()
        let small = CompressionPlan(source: source, settings: CompressionSettings(dimensionPercent: lower))
        let large = CompressionPlan(source: source, settings: CompressionSettings(dimensionPercent: higher))
        #expect(small.estimatedBytes <= large.estimatedBytes)
        #expect(small.size.pixelCount < large.size.pixelCount)
    }

    @Test(arguments: [(10, 20), (20, 24), (24, 30)])
    func moreFramesNeverWeighLess(lower: Int, higher: Int) {
        let source = SourceVideo.phone()
        let few = CompressionPlan(source: source, settings: CompressionSettings(frameRate: lower))
        let many = CompressionPlan(source: source, settings: CompressionSettings(frameRate: higher))
        #expect(few.estimatedBytes < many.estimatedBytes)
    }

    @Test func hevcWeighsLessThanH264() {
        let source = SourceVideo.phone()
        let h264 = CompressionPlan(source: source, settings: CompressionSettings(codec: .h264))
        let hevc = CompressionPlan(source: source, settings: CompressionSettings(codec: .hevc))
        #expect(hevc.estimatedBytes < h264.estimatedBytes)
        #expect(hevc.codec == .hevc)
    }

    @Test func removingAudioDropsItsBitRate() {
        let source = SourceVideo.phone()
        let with = CompressionPlan(source: source, settings: CompressionSettings())
        let without = CompressionPlan(source: source, settings: CompressionSettings(removesAudio: true))
        #expect(without.audioBitsPerSecond == 0)
        #expect(without.estimatedBytes < with.estimatedBytes)
        #expect(without.videoBitsPerSecond == with.videoBitsPerSecond)
    }

    @Test func aSilentVideoHasNoAudioToPlan() {
        #expect(CompressionPlan(source: .phone(hasAudio: false), settings: CompressionSettings()).audioBitsPerSecond == 0)
    }

    @Test(arguments: [(0.0, 128_000.0), (.nan, 128_000), (-5, 128_000), (32_000, 64_000), (96_000, 96_000), (320_000, 128_000), (.infinity, 128_000)])
    func audioRateStaysWithinWhatAACTakes(sourceRate: Double, expected: Double) {
        let plan = CompressionPlan(source: .phone(audioBitsPerSecond: sourceRate), settings: CompressionSettings())
        #expect(plan.audioBitsPerSecond == expected)
    }

    @Test func aVideoThatIsAlreadyLightIsNeverEstimatedHeavier() {
        // 480p at 1 Mb/s: there is little to save, and the estimate never goes above the file.
        let source = SourceVideo.phone(size: PixelSize(width: 854, height: 480), videoBitsPerSecond: 300_000, audioBitsPerSecond: 64_000)
        for quality in stride(from: 10, through: 100, by: 10) {
            let plan = CompressionPlan(source: source, settings: CompressionSettings(dimensionPercent: 100, qualityPercent: quality))
            #expect(plan.estimatedBytes <= source.bytes)
            #expect(plan.savedFraction(of: source) >= 0)
        }
    }

    @Test func theVideoBitRateNeverFallsUnderTheFloor() {
        let source = SourceVideo.phone(size: PixelSize(width: 160, height: 120), frameRate: 10, videoBitsPerSecond: 50_000)
        let plan = CompressionPlan(source: source, settings: CompressionSettings(dimensionPercent: 10, qualityPercent: 10))
        #expect(plan.videoBitsPerSecond == CompressionPlan.minimumVideoBitsPerSecond)
    }

    @Test func theFileSizeStandsInForAMissingBitRate() {
        let known = CompressionPlan(source: .phone(), settings: CompressionSettings())
        let derived = CompressionPlan(source: .phone(videoBitsPerSecond: 0, bytes: SourceVideo.phone().bytes), settings: CompressionSettings())
        #expect(derived.videoBitsPerSecond == known.videoBitsPerSecond)
    }

    // MARK: - Target in MB

    @Test(arguments: [5.0, 10, 20, 30])
    func aReachableTargetLandsOnIt(megabytes: Double) {
        let plan = CompressionPlan(source: .phone(), settings: CompressionSettings(targetMegabytes: megabytes))
        #expect(plan.targetFit == .fits)
        let target = megabytes * 1_000_000
        #expect(abs(Double(plan.estimatedBytes) - target) / target < 0.01)
    }

    @Test func aTargetBelowTheFloorIsTooSmall() {
        // A minute at the lowest bit rate with audio is about 1.7 MB.
        let plan = CompressionPlan(source: .phone(), settings: CompressionSettings(targetMegabytes: 1))
        #expect(plan.targetFit == .tooSmall)
        #expect(plan.videoBitsPerSecond == CompressionPlan.minimumVideoBitsPerSecond)
        #expect(plan.estimatedBytes > 1_000_000)
    }

    @Test func aTargetAboveTheCleanCopyIsAlreadyMet() {
        let source = SourceVideo.phone()
        let plan = CompressionPlan(source: source, settings: CompressionSettings(targetMegabytes: 120))
        let clean = CompressionPlan(source: source, settings: CompressionSettings(qualityPercent: 100))
        #expect(plan.targetFit == .alreadySmaller)
        #expect(plan.estimatedBytes == clean.estimatedBytes)
        #expect(plan.estimatedBytes < 120_000_000)
    }

    @Test func theTargetIgnoresTheQualitySlider() {
        let low = CompressionPlan(source: .phone(), settings: CompressionSettings(qualityPercent: 10, targetMegabytes: 20))
        let high = CompressionPlan(source: .phone(), settings: CompressionSettings(qualityPercent: 100, targetMegabytes: 20))
        #expect(low == high)
    }

    @Test func removingAudioLeavesMoreOfTheTargetToThePicture() {
        let with = CompressionPlan(source: .phone(), settings: CompressionSettings(targetMegabytes: 10))
        let without = CompressionPlan(source: .phone(), settings: CompressionSettings(targetMegabytes: 10, removesAudio: true))
        #expect(without.videoBitsPerSecond > with.videoBitsPerSecond)
    }

    // MARK: - Absurd sources

    @Test(arguments: [
        SourceVideo.phone(duration: 0),
        .phone(duration: .nan),
        .phone(duration: -30),
        .phone(duration: .infinity),
        .phone(size: PixelSize(width: 0, height: 0)),
        .phone(bytes: 0),
    ])
    func anUnusableSourceIsEstimatedAtZeroWithoutCrashing(source: SourceVideo) {
        let plan = CompressionPlan(source: source, settings: CompressionSettings(targetMegabytes: 10))
        #expect(plan.estimatedBytes == 0)
        #expect(plan.videoBitsPerSecond.isFinite)
        #expect(plan.savedFraction(of: source) >= 0)
    }

    @Test func aTwoHourFourKVideoStaysInRange() {
        let source = SourceVideo.phone(duration: 7_200, size: PixelSize(width: 3840, height: 2160), frameRate: 60, videoBitsPerSecond: 50_000_000)
        let plan = CompressionPlan(source: source, settings: CompressionSettings())
        #expect(plan.estimatedBytes > 0)
        #expect(plan.estimatedBytes < source.bytes)
        #expect(plan.size == PixelSize(width: 3072, height: 1728))
    }

    @Test func savedFractionOfAnEmptySourceIsZero() {
        let source = SourceVideo.phone(bytes: 0)
        #expect(CompressionPlan(source: source, settings: CompressionSettings()).savedFraction(of: source) == 0)
    }

    @Test(arguments: [("MOV", false, OutputFormat.mov), ("mp4", false, .mp4), ("mov", true, .mp4)])
    func formatFollowsTheSettings(ext: String, convertsToMP4: Bool, expected: OutputFormat) {
        let plan = CompressionPlan(source: .phone(fileExtension: ext), settings: CompressionSettings(convertsToMP4: convertsToMP4))
        #expect(plan.format == expected)
    }
}
