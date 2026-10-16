import AVFoundation
@testable import SbuShrink

/// Writes small real videos for the engine tests: a sliding gradient with grain (so the encoder has work to do)
/// and an optional 440 Hz tone.
nonisolated enum TestVideo {
    struct Options: Sendable {
        var width = 640
        var height = 360
        var frameRate = 30
        var seconds = 2.0
        var bitsPerSecond = 8_000_000
        var codec: AVVideoCodecType = .h264
        var hasAudio = true
        /// Stored as the track's preferred transform, like a phone held upright.
        var transform: CGAffineTransform = .identity
        var fileType: AVFileType = .mov
    }

    private static let sampleRate = 44_100.0

    /// A new file in the temporary directory; the caller removes it.
    @concurrent
    static func make(_ options: Options = Options()) async throws -> URL {
        let ext = options.fileType == .mp4 ? "mp4" : "mov"
        let url = FileManager.default.temporaryDirectory.appending(path: "test-\(UUID().uuidString).\(ext)")
        let writer = try AVAssetWriter(outputURL: url, fileType: options.fileType)

        let video = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: options.codec,
            AVVideoWidthKey: options.width,
            AVVideoHeightKey: options.height,
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: options.bitsPerSecond],
        ])
        video.expectsMediaDataInRealTime = false
        video.transform = options.transform
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: video, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: options.width,
            kCVPixelBufferHeightKey as String: options.height,
        ])
        writer.add(video)

        var audio: AVAssetWriterInput?
        if options.hasAudio {
            let input = AVAssetWriterInput(mediaType: .audio, outputSettings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 1,
                AVSampleRateKey: sampleRate,
                AVEncoderBitRateKey: 96_000,
            ])
            input.expectsMediaDataInRealTime = false
            writer.add(input)
            audio = input
        }

        guard writer.startWriting() else { throw writer.error ?? CompressionError.encodingFailed }
        writer.startSession(atSourceTime: .zero)

        let frames = Int(options.seconds * Double(options.frameRate))
        let samplesPerFrame = Int(sampleRate) / options.frameRate
        var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
        // Each input takes data when it is ready: the writer holds one back while the other lags.
        var frame = 0
        var chunk = audio == nil ? frames : 0
        var idle = 0
        while frame < frames || chunk < frames {
            if writer.status == .failed { throw writer.error ?? CompressionError.encodingFailed }
            var moved = false
            if frame < frames, video.isReadyForMoreMediaData {
                let time = CMTime(value: CMTimeValue(frame), timescale: CMTimeScale(options.frameRate))
                let buffer = try frameBuffer(adaptor: adaptor, width: options.width, height: options.height, frame: frame, seed: &seed)
                guard adaptor.append(buffer, withPresentationTime: time) else { throw writer.error ?? CompressionError.encodingFailed }
                frame += 1
                moved = true
                if frame == frames { video.markAsFinished() }
            }
            if let audio, chunk < frames, audio.isReadyForMoreMediaData {
                let sample = try tone(start: chunk * samplesPerFrame, count: samplesPerFrame)
                guard audio.append(sample) else { throw writer.error ?? CompressionError.encodingFailed }
                chunk += 1
                moved = true
                if chunk == frames { audio.markAsFinished() }
            }
            if moved {
                idle = 0
            } else {
                idle += 1
                if idle > 10_000 { throw TestVideoError.stuck("frame \(frame) chunk \(chunk)", writer.status.rawValue) }
                try await Task.sleep(for: .milliseconds(1))
            }
        }
        await writer.finishWriting()
        guard writer.status == .completed else { throw writer.error ?? CompressionError.encodingFailed }
        return url
    }

    private static func frameBuffer(adaptor: AVAssetWriterInputPixelBufferAdaptor, width: Int, height: Int, frame: Int, seed: inout UInt64) throws -> CVPixelBuffer {
        var buffer: CVPixelBuffer?
        if let pool = adaptor.pixelBufferPool {
            CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
        } else {
            CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32BGRA, nil, &buffer)
        }
        guard let buffer else { throw CompressionError.encodingFailed }
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let base = CVPixelBufferGetBaseAddress(buffer) else { throw CompressionError.encodingFailed }
        let rowWords = CVPixelBufferGetBytesPerRow(buffer) / 8
        let words = rowWords * height
        let pointer = base.bindMemory(to: UInt64.self, capacity: words)
        for index in 0..<words {
            // A diagonal gradient that slides each frame, like a camera pan, with grain on top.
            let row = index / rowWords
            let column = index % rowWords
            let level = UInt64((row + column * 2 + frame * 3) & 0xFF) &* 0x0101_0101_0101_0101
            // xorshift64: fast, repeatable noise.
            seed ^= seed << 13
            seed ^= seed >> 7
            seed ^= seed << 17
            pointer[index] = level ^ (seed & 0x0303_0303_0303_0303)
        }
        return buffer
    }

    private static func tone(start: Int, count: Int) throws -> CMSampleBuffer {
        var description = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked,
            mBytesPerPacket: 2,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )
        var format: CMAudioFormatDescription?
        CMAudioFormatDescriptionCreate(allocator: nil, asbd: &description, layoutSize: 0, layout: nil, magicCookieSize: 0, magicCookie: nil, extensions: nil, formatDescriptionOut: &format)

        var samples = (0..<count).map { index in
            Int16(sin(2 * Double.pi * 440 * Double(start + index) / sampleRate) * 8_000)
        }
        let length = count * 2
        var block: CMBlockBuffer?
        CMBlockBufferCreateWithMemoryBlock(allocator: nil, memoryBlock: nil, blockLength: length, blockAllocator: nil, customBlockSource: nil, offsetToData: 0, dataLength: length, flags: 0, blockBufferOut: &block)
        guard let block, let format else { throw CompressionError.encodingFailed }
        samples.withUnsafeMutableBytes { bytes in
            _ = CMBlockBufferReplaceDataBytes(with: bytes.baseAddress!, blockBuffer: block, offsetIntoDestination: 0, dataLength: length)
        }
        var sample: CMSampleBuffer?
        CMAudioSampleBufferCreateReadyWithPacketDescriptions(
            allocator: nil,
            dataBuffer: block,
            formatDescription: format,
            sampleCount: count,
            presentationTimeStamp: CMTime(value: CMTimeValue(start), timescale: CMTimeScale(sampleRate)),
            packetDescriptions: nil,
            sampleBufferOut: &sample
        )
        guard let sample else { throw CompressionError.encodingFailed }
        return sample
    }
}

enum TestVideoError: Error {
    case stuck(String, Int)
}
