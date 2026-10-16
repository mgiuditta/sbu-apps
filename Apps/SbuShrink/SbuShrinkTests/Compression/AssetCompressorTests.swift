import AVFoundation
import Foundation
import os
import Testing
@testable import SbuShrink

/// Real encodes of small generated videos on the simulator's encoder.
@Suite(.serialized)
struct AssetCompressorTests {
    private static func output(_ ext: String) -> URL {
        FileManager.default.temporaryDirectory.appending(path: "out-\(UUID().uuidString).\(ext)")
    }

    private static func compress(_ input: URL, settings: CompressionSettings) async throws -> (SourceVideo, CompressionPlan, SourceVideo, [Double]) {
        let source = try await VideoProbe.source(at: input)
        let plan = CompressionPlan(source: source, settings: settings)
        let output = output(plan.format.fileExtension)
        let reports = OSAllocatedUnfairLock<[Double]>(initialState: [])
        let bytes = try await AssetCompressor().compress(input, plan: plan, to: output, progress: { value in
            reports.withLock { $0.append(value) }
        })
        let result = try await VideoProbe.source(at: output)
        #expect(bytes == result.bytes)
        try? FileManager.default.removeItem(at: output)
        return (source, plan, result, reports.withLock { $0 })
    }

    @Test func probeReadsWhatTheFileSays() async throws {
        let input = try await TestVideo.make()
        defer { try? FileManager.default.removeItem(at: input) }
        let source = try await VideoProbe.source(at: input)
        #expect(source.size == PixelSize(width: 640, height: 360))
        #expect(abs(source.duration - 2) < 0.1)
        #expect(abs(source.frameRate - 30) < 0.5)
        #expect(source.hasAudio)
        #expect(source.bytes > 0)
        #expect(source.fileExtension == "mov")
    }

    @Test func theSuggestedSettingsMakeASmallerUprightCopyWithSound() async throws {
        let input = try await TestVideo.make()
        defer { try? FileManager.default.removeItem(at: input) }
        let (source, plan, result, reports) = try await Self.compress(input, settings: CompressionSettings())

        #expect(result.size == plan.size)
        #expect(result.size == PixelSize(width: 512, height: 288))
        #expect(abs(result.frameRate - 24) < 1)
        #expect(abs(result.duration - source.duration) < 0.2)
        #expect(result.hasAudio)
        #expect(result.bytes < source.bytes)
        #expect(reports.last == 1)
        #expect(reports == reports.sorted())
        #expect(reports.allSatisfy { (0...1).contains($0) })
    }

    @Test func theRealSizeLandsNearTheEstimate() async throws {
        let input = try await TestVideo.make(.init(seconds: 3))
        defer { try? FileManager.default.removeItem(at: input) }
        let (_, plan, result, _) = try await Self.compress(input, settings: CompressionSettings(qualityPercent: 50))
        // The encoder aims at the average rate; short clips land within a quarter of it.
        let ratio = Double(result.bytes) / Double(plan.estimatedBytes)
        #expect((0.6...1.25).contains(ratio), "estimate \(plan.estimatedBytes), real \(result.bytes)")
    }

    @Test func removingAudioLeavesOnlyThePicture() async throws {
        let input = try await TestVideo.make()
        defer { try? FileManager.default.removeItem(at: input) }
        let (_, _, result, _) = try await Self.compress(input, settings: CompressionSettings(removesAudio: true))
        #expect(!result.hasAudio)
    }

    @Test func aSilentSourceCompressesWithoutAudio() async throws {
        let input = try await TestVideo.make(.init(hasAudio: false))
        defer { try? FileManager.default.removeItem(at: input) }
        let (_, _, result, _) = try await Self.compress(input, settings: CompressionSettings())
        #expect(!result.hasAudio)
    }

    @Test func movBecomesMP4WhenAsked() async throws {
        let input = try await TestVideo.make()
        defer { try? FileManager.default.removeItem(at: input) }
        let (_, plan, result, _) = try await Self.compress(input, settings: CompressionSettings(convertsToMP4: true))
        #expect(plan.format == .mp4)
        #expect(result.fileExtension == "mp4")
    }

    @Test func hevcSourceToHEVCCopy() async throws {
        let input = try await TestVideo.make(.init(codec: .hevc, fileType: .mp4))
        defer { try? FileManager.default.removeItem(at: input) }
        let (_, plan, result, _) = try await Self.compress(input, settings: CompressionSettings(codec: .hevc))
        #expect(plan.format == .mp4)
        #expect(result.size == plan.size)
    }

    @Test func aPortraitVideoStaysPortrait() async throws {
        // Recorded landscape and rotated by its transform, as the camera does for portrait.
        let input = try await TestVideo.make(.init(transform: CGAffineTransform(rotationAngle: .pi / 2)))
        defer { try? FileManager.default.removeItem(at: input) }
        let source = try await VideoProbe.source(at: input)
        #expect(source.size == PixelSize(width: 360, height: 640))
        let (_, plan, result, _) = try await Self.compress(input, settings: CompressionSettings(dimensionPercent: 50))
        #expect(plan.size == PixelSize(width: 180, height: 320))
        #expect(result.size == PixelSize(width: 180, height: 320))
    }

    @Test func aTargetIsHonouredWithinTheEncodersMargin() async throws {
        // 4 s of 720p: 1 MB leaves about 1.8 Mb/s for the picture, under the clean rate.
        let input = try await TestVideo.make(.init(width: 1280, height: 720, seconds: 4, bitsPerSecond: 20_000_000))
        defer { try? FileManager.default.removeItem(at: input) }
        let (_, plan, result, _) = try await Self.compress(input, settings: CompressionSettings(targetMegabytes: 1))
        #expect(plan.targetFit == .fits)
        #expect(Double(result.bytes) < 1_250_000)
    }

    @Test func cancellingStopsAndLeavesNoFile() async throws {
        let input = try await TestVideo.make(.init(seconds: 6))
        defer { try? FileManager.default.removeItem(at: input) }
        let source = try await VideoProbe.source(at: input)
        let plan = CompressionPlan(source: source, settings: CompressionSettings(dimensionPercent: 100, qualityPercent: 100))
        let output = Self.output("mov")
        let task = Task {
            try await AssetCompressor().compress(input, plan: plan, to: output, progress: { _ in })
        }
        task.cancel()
        await #expect(throws: CompressionError.cancelled) {
            try await task.value
        }
        #expect(!FileManager.default.fileExists(atPath: output.path()))
    }

    @Test func aFileThatIsNotAVideoIsUnreadable() async throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "not-a-video-\(UUID().uuidString).mov")
        try Data("not a video".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        await #expect(throws: CompressionError.unreadable) {
            try await VideoProbe.source(at: url)
        }
        await #expect(throws: CompressionError.unreadable) {
            _ = try await AssetCompressor().compress(url, plan: CompressionPlan(source: .phone(), settings: CompressionSettings()), to: Self.output("mov"), progress: { _ in })
        }
    }

    @Test func aMissingFileIsUnreadable() async {
        let url = FileManager.default.temporaryDirectory.appending(path: "missing-\(UUID().uuidString).mov")
        await #expect(throws: CompressionError.unreadable) {
            try await VideoProbe.source(at: url)
        }
    }

    @Test func anExistingOutputIsReplaced() async throws {
        let input = try await TestVideo.make()
        defer { try? FileManager.default.removeItem(at: input) }
        let source = try await VideoProbe.source(at: input)
        let plan = CompressionPlan(source: source, settings: CompressionSettings())
        let output = Self.output("mov")
        try Data("old".utf8).write(to: output)
        defer { try? FileManager.default.removeItem(at: output) }
        _ = try await AssetCompressor().compress(input, plan: plan, to: output, progress: { _ in })
        #expect(try await VideoProbe.source(at: output).size == plan.size)
    }

    @Test(arguments: [(30.0, 2_000), (29.97, 2_002), (24, 2_500), (60, 1_000), (59.94, 1_001), (0, 2_000), (.nan, 2_000)])
    func frameDurationKeepsBroadcastRatesExact(rate: Double, value: Int64) {
        let duration = AssetCompressor.frameDuration(rate)
        #expect(duration.timescale == 60_000)
        #expect(duration.value == value)
    }
}
