import Testing
@testable import SbuShrink

struct SourceVideoTests {
    @Test func aPhoneVideoIsUsable() {
        #expect(SourceVideo.phone().isUsable)
    }

    @Test(arguments: [
        SourceVideo.phone(duration: 0),
        .phone(duration: -1),
        .phone(duration: .nan),
        .phone(duration: .infinity),
        .phone(size: PixelSize(width: 0, height: 1080)),
        .phone(size: PixelSize(width: 1920, height: -2)),
        .phone(bytes: 0),
        .phone(bytes: -100),
    ])
    func aVideoWithoutLengthPictureOrBytesIsNotUsable(source: SourceVideo) {
        #expect(!source.isUsable)
    }

    @Test(arguments: [
        (30.0, 30.0), (29.97, 29.97), (240, 240), (1, 1),
        (0, 30), (-24, 30), (0.5, 30), (.nan, 30), (.infinity, 30), (5_000, 30),
    ])
    func frameRateFallsBackTo30WhenAbsurd(rate: Double, expected: Double) {
        #expect(SourceVideo.phone(frameRate: rate).effectiveFrameRate == expected)
    }

    @Test func videoRateComesFromTheFileWhenItSaysIt() {
        #expect(SourceVideo.phone(videoBitsPerSecond: 5_000_000).effectiveVideoBitsPerSecond == 5_000_000)
    }

    @Test(arguments: [0.0, -1, .nan, .infinity])
    func videoRateIsDerivedFromTheSizeWhenTheFileDoesNotSay(rate: Double) {
        // 75 MB in 60 s is 10 Mb/s, of which 128 kb/s are audio.
        let source = SourceVideo.phone(videoBitsPerSecond: rate, bytes: 75_000_000)
        #expect(source.effectiveVideoBitsPerSecond == 10_000_000 - 128_000)
    }

    @Test func derivedRateIgnoresAbsurdAudioAndNeverGoesNegative() {
        #expect(SourceVideo.phone(videoBitsPerSecond: 0, audioBitsPerSecond: .nan, bytes: 75_000_000).effectiveVideoBitsPerSecond == 10_000_000)
        #expect(SourceVideo.phone(videoBitsPerSecond: 0, audioBitsPerSecond: 1e12, bytes: 1_000).effectiveVideoBitsPerSecond == 0)
        #expect(SourceVideo.phone(duration: 0, videoBitsPerSecond: 0, bytes: 1_000).effectiveVideoBitsPerSecond == 0)
    }
}
