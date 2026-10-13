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
}
