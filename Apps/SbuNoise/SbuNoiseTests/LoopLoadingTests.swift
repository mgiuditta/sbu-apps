import AVFAudio
import Foundation
import Testing
@testable import SbuNoise

struct LoopLoadingTests {
    /// The research for the catalog measured this on macOS; the loop is only gapless if iOS also
    /// strips the AAC priming and remainder frames.
    @Test func aacLoopHasExactlyTheEncodedFrames() throws {
        let frames: AVAudioFrameCount = 44_100
        let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).caf")
        defer { try? FileManager.default.removeItem(at: url) }

        let format = try #require(AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2))
        let source = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        source.frameLength = frames
        do {
            let file = try AVAudioFile(forWriting: url, settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 2,
                AVEncoderBitRateKey: 96_000,
            ])
            try file.write(from: source)
        }

        let buffer = try SoundEngine.loadLoop(url)
        #expect(buffer.frameLength == frames)
    }

    /// The bundle's loops carry wrap-around padding at both ends, which loading skips.
    @Test func loadingSkipsThePadding() throws {
        let padding = SoundEngine.loopPadding
        let frames = AVAudioFrameCount(44_100 + 2 * padding)
        let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).wav")
        defer { try? FileManager.default.removeItem(at: url) }

        let format = try #require(AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1))
        let source = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        source.frameLength = frames
        // Silence in the padding, a constant in the loop: linear PCM keeps it exact, so the fade
        // from the trailing padding into the loop's start is visible.
        let samples = try #require(source.floatChannelData?[0])
        for frame in 0..<Int(frames) {
            samples[frame] = (Int64(frame) >= padding && Int64(frame) < Int64(frames) - padding) ? 0.5 : 0
        }
        do {
            let file = try AVAudioFile(forWriting: url, settings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
            ])
            try file.write(from: source)
        }

        let buffer = try SoundEngine.loadLoop(url, padding: padding)
        #expect(buffer.frameLength == 44_100)
        let loaded = try #require(buffer.floatChannelData?[0])
        #expect(loaded[0] == 0, "The loop starts as the continuation of its end")
        #expect(abs(loaded[512] - 0.25) < 0.001)
        #expect(loaded[1_024] == 0.5 && loaded[44_099] == 0.5)
    }
}
