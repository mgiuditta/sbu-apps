import AVFoundation

/// Compresses on the device with AVAssetReader and AVAssetWriter; the system encoder runs on
/// the media engine (VideoToolbox).
///
/// A video composition scales, turns the picture upright and drops frames to the plan's rate,
/// and maps HDR to standard dynamic range so the copy plays everywhere.
nonisolated struct AssetCompressor: VideoCompressor {
    /// Sample rate of the AAC track.
    private static let audioSampleRate = 44_100
    /// A key frame at least every two seconds, so the copy seeks quickly.
    private static let keyFrameSeconds = 2.0

    @concurrent
    func compress(_ input: URL, plan: CompressionPlan, to output: URL, progress: @escaping @Sendable (Double) -> Void) async throws {
        try? FileManager.default.removeItem(at: output)
        do {
            try await Self.write(AVURLAsset(url: input), plan: plan, to: output, progress: progress)
        } catch {
            try? FileManager.default.removeItem(at: output)
            switch error {
            case let error as CompressionError: throw error
            case is CancellationError: throw CompressionError.cancelled
            default: throw CompressionError.unreadable
            }
        }
    }

    /// The tracks and their properties.
    private struct Tracks {
        let video: AVAssetTrack
        let audio: [AVAssetTrack]
        let duration: CMTime
        let naturalSize: CGSize
        let transform: CGAffineTransform
    }

    private static func tracks(of asset: AVURLAsset, keepsAudio: Bool) async throws -> Tracks {
        let duration = try await asset.load(.duration)
        guard let video = try await asset.loadTracks(withMediaType: .video).first, duration.seconds > 0 else {
            throw CompressionError.unreadable
        }
        let (naturalSize, transform) = try await video.load(.naturalSize, .preferredTransform)
        let audio = keepsAudio ? try await asset.loadTracks(withMediaType: .audio) : []
        return Tracks(video: video, audio: audio, duration: duration, naturalSize: naturalSize, transform: transform)
    }

    // MARK: - Writing

    /// Reader, writer and samples never leave this function. While the encoder is busy it
    /// sleeps a moment instead of blocking a thread, and it stops at the first check after a
    /// cancellation.
    private static func write(_ asset: AVURLAsset, plan: CompressionPlan, to output: URL, progress: @Sendable (Double) -> Void) async throws {
        let tracks = try await tracks(of: asset, keepsAudio: plan.audioBitsPerSecond > 0)
        let reader: AVAssetReader
        let writer: AVAssetWriter
        do {
            reader = try AVAssetReader(asset: asset)
            writer = try AVAssetWriter(outputURL: output, fileType: plan.format.fileType)
        } catch {
            throw CompressionError.unreadable
        }
        writer.shouldOptimizeForNetworkUse = true

        let videoOutput = AVAssetReaderVideoCompositionOutput(
            videoTracks: [tracks.video],
            videoSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
        )
        videoOutput.videoComposition = composition(tracks: tracks, plan: plan)
        videoOutput.alwaysCopiesSampleData = false
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings(plan))
        videoInput.expectsMediaDataInRealTime = false

        var audioOutput: AVAssetReaderAudioMixOutput?
        var audioInput: AVAssetWriterInput?
        if !tracks.audio.isEmpty {
            let mix = AVAssetReaderAudioMixOutput(audioTracks: tracks.audio, audioSettings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: audioSampleRate,
            ])
            mix.alwaysCopiesSampleData = false
            let input = AVAssetWriterInput(mediaType: .audio, outputSettings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: audioSampleRate,
                AVEncoderBitRateKey: Int(plan.audioBitsPerSecond),
            ])
            input.expectsMediaDataInRealTime = false
            if reader.canAdd(mix), writer.canAdd(input) {
                audioOutput = mix
                audioInput = input
            }
        }

        guard reader.canAdd(videoOutput), writer.canAdd(videoInput) else { throw CompressionError.unreadable }
        reader.add(videoOutput)
        writer.add(videoInput)
        if let audioOutput, let audioInput {
            reader.add(audioOutput)
            writer.add(audioInput)
        }

        guard reader.startReading() else { throw CompressionError.unreadable }
        guard writer.startWriting() else {
            reader.cancelReading()
            throw CompressionError.encodingFailed
        }
        writer.startSession(atSourceTime: .zero)

        let duration = tracks.duration.seconds
        var videoDone = false
        var audioDone = audioOutput == nil
        var lastReported = -1.0
        while !(videoDone && audioDone) {
            if Task.isCancelled {
                reader.cancelReading()
                writer.cancelWriting()
                throw CompressionError.cancelled
            }
            var moved = false
            if !videoDone, videoInput.isReadyForMoreMediaData {
                if let sample = videoOutput.copyNextSampleBuffer() {
                    guard videoInput.append(sample) else { break }
                    moved = true
                    let fraction = (CMSampleBufferGetPresentationTimeStamp(sample).seconds / duration).clamped(to: 0...1)
                    // A report per percent is enough for a progress bar.
                    if fraction - lastReported >= 0.01 {
                        lastReported = fraction
                        progress(fraction)
                    }
                } else {
                    videoInput.markAsFinished()
                    videoDone = true
                }
            }
            if !audioDone, let audioOutput, let audioInput, audioInput.isReadyForMoreMediaData {
                if let sample = audioOutput.copyNextSampleBuffer() {
                    guard audioInput.append(sample) else { break }
                    moved = true
                } else {
                    audioInput.markAsFinished()
                    audioDone = true
                }
            }
            if !moved, !(videoDone && audioDone) {
                // The encoder is busy: give it a moment instead of spinning.
                try? await Task.sleep(for: .milliseconds(2))
            }
        }

        guard reader.status != .failed, writer.status == .writing, videoDone, audioDone else {
            reader.cancelReading()
            writer.cancelWriting()
            throw CompressionError.encodingFailed
        }

        await writer.finishWriting()
        guard writer.status == .completed else { throw CompressionError.encodingFailed }
        progress(1)
    }

    private static func composition(tracks: Tracks, plan: CompressionPlan) -> AVMutableVideoComposition {
        let upright = CGRect(origin: .zero, size: tracks.naturalSize).applying(tracks.transform)
        let scaleX = CGFloat(plan.size.width) / max(abs(upright.width), 1)
        let scaleY = CGFloat(plan.size.height) / max(abs(upright.height), 1)
        // Turn the picture upright, move it back to the origin, then scale it to the plan.
        let transform = tracks.transform
            .concatenating(CGAffineTransform(translationX: -upright.minX, y: -upright.minY))
            .concatenating(CGAffineTransform(scaleX: scaleX, y: scaleY))

        let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: tracks.video)
        layer.setTransform(transform, at: .zero)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: tracks.duration)
        instruction.layerInstructions = [layer]

        let composition = AVMutableVideoComposition()
        composition.instructions = [instruction]
        composition.renderSize = CGSize(width: plan.size.width, height: plan.size.height)
        composition.frameDuration = frameDuration(plan.frameRate)
        composition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
        composition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
        composition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
        return composition
    }

    /// One frame at `rate`, in a time scale that keeps 29.97 and 59.94 exact.
    static func frameDuration(_ rate: Double) -> CMTime {
        let timescale: CMTimeScale = 60_000
        let safeRate = rate.isFinite && rate >= 1 ? rate : 30
        return CMTime(value: CMTimeValue((Double(timescale) / safeRate).rounded()), timescale: timescale)
    }

    private static func videoSettings(_ plan: CompressionPlan) -> [String: Any] {
        var compression: [String: Any] = [
            AVVideoAverageBitRateKey: Int(plan.videoBitsPerSecond),
            AVVideoExpectedSourceFrameRateKey: Int(plan.frameRate.rounded()),
            AVVideoMaxKeyFrameIntervalKey: max(Int((plan.frameRate * keyFrameSeconds).rounded()), 1),
        ]
        if plan.codec == .h264 {
            compression[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel
        }
        return [
            AVVideoCodecKey: plan.codec.avCodec,
            AVVideoWidthKey: plan.size.width,
            AVVideoHeightKey: plan.size.height,
            AVVideoCompressionPropertiesKey: compression,
            AVVideoColorPropertiesKey: [
                AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
                AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2,
            ],
        ]
    }
}
