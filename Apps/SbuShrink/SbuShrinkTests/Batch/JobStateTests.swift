import Testing
@testable import SbuShrink

struct JobStateTests {
    @Test(arguments: [
        (JobState.loading, false, 0.0),
        (.waiting, false, 0),
        (.compressing(0.4), false, 0.4),
        (.done(bytes: 1, saved: true), true, 1),
        (.notSmaller, true, 1),
        (.failed, true, 1),
        (.cancelled, true, 1),
        (.unreadable, true, 0),
    ])
    func finishedAndFraction(state: JobState, isFinished: Bool, fraction: Double) {
        #expect(state.isFinished == isFinished)
        #expect(state.fraction == fraction)
    }

    @Test(arguments: [(-1.0, 0.0), (2, 1), (.nan, 0), (.infinity, 0), (-.infinity, 0)])
    func anAbsurdProgressIsClamped(value: Double, expected: Double) {
        #expect(JobState.compressing(value).fraction == expected)
    }

    @Test func aJobIsInTheRunOnlyOnceRead() {
        #expect(!VideoJob(assetID: nil).isInRun)
        #expect(!VideoJob(assetID: nil, source: .phone(), state: .unreadable).isInRun)
        #expect(!VideoJob(assetID: nil, state: .waiting).isInRun)
        #expect(VideoJob(assetID: nil, source: .phone(), state: .waiting).isInRun)
        #expect(VideoJob(assetID: nil, source: .phone(), state: .failed).isInRun)
    }
}
