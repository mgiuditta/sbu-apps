import Foundation
import Testing
@testable import SbuShrink

struct BatchProgressTests {
    private static func job(_ state: JobState, seconds: Double = 60) -> VideoJob {
        VideoJob(assetID: nil, name: "v", source: .phone(duration: seconds), state: state)
    }

    @Test func anEmptyBatchIsAtZeroOfZero() {
        let progress = BatchProgress(jobs: [])
        #expect(progress.fraction == 0)
        #expect(progress.current == 0)
        #expect(progress.total == 0)
    }

    @Test func theOriginalsScreenshotIsVideoTwoOfFive() {
        let jobs = [Self.job(.done(bytes: 1, saved: true)), Self.job(.compressing(0.88)), Self.job(.waiting), Self.job(.waiting), Self.job(.waiting)]
        let progress = BatchProgress(jobs: jobs)
        #expect(progress.current == 2)
        #expect(progress.total == 5)
        #expect(abs(progress.fraction - 1.88 / 5) < 1e-9)
    }

    @Test func longerVideosWeighMore() {
        let jobs = [Self.job(.done(bytes: 1, saved: true), seconds: 300), Self.job(.waiting, seconds: 100)]
        #expect(BatchProgress(jobs: jobs).fraction == 0.75)
    }

    @Test(arguments: [0.0, -1, .nan, .infinity])
    func anAbsurdDurationWeighsLikeOneSecond(seconds: Double) {
        let jobs = [Self.job(.done(bytes: 1, saved: true), seconds: seconds), Self.job(.waiting, seconds: 1)]
        #expect(BatchProgress(jobs: jobs).fraction == 0.5)
    }

    @Test func everyEndingCountsAsFinished() {
        let jobs = [Self.job(.done(bytes: 1, saved: false)), Self.job(.notSmaller), Self.job(.failed), Self.job(.cancelled)]
        let progress = BatchProgress(jobs: jobs)
        #expect(progress.fraction == 1)
        #expect(progress.current == 4)
        #expect(progress.total == 4)
    }

    @Test func videosOutOfTheRunAreNotCounted() {
        let unread = VideoJob(assetID: nil, state: .unreadable)
        let loading = VideoJob(assetID: nil, state: .loading)
        let progress = BatchProgress(jobs: [unread, loading, Self.job(.waiting)])
        #expect(progress.total == 1)
        #expect(progress.current == 1)
        #expect(progress.fraction == 0)
    }

    @Test func betweenTwoVideosItShowsTheNextOne() {
        let progress = BatchProgress(jobs: [Self.job(.done(bytes: 1, saved: true)), Self.job(.waiting)])
        #expect(progress.current == 2)
    }

    @Test(arguments: [-0.5, 1.7, .nan, .infinity])
    func anAbsurdProgressReportStaysWithinTheBar(value: Double) {
        let fraction = BatchProgress(jobs: [Self.job(.compressing(value))]).fraction
        #expect((0...1).contains(fraction))
    }
}
