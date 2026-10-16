import Foundation
import Testing
@testable import SbuShrink

struct BatchSummaryTests {
    private static func job(_ state: JobState, bytes: Int64 = 100_000_000, assetID: String? = "id") -> VideoJob {
        VideoJob(assetID: assetID, name: "v", source: .phone(bytes: bytes), state: state)
    }

    @Test func theOriginalsScreenshotAddsUp() {
        // Before 1,1 GB, after 662,8 MB, savings 478,7 MB (rounded on screen).
        let jobs = [
            Self.job(.done(bytes: 300_000_000, saved: true), bytes: 500_800_000, assetID: "a"),
            Self.job(.done(bytes: 362_800_000, saved: true), bytes: 640_700_000, assetID: "b"),
        ]
        let summary = BatchSummary(jobs: jobs)
        #expect(summary.beforeBytes == 1_141_500_000)
        #expect(summary.afterBytes == 662_800_000)
        #expect(summary.savedBytes == 478_700_000)
        #expect(summary.compressed == 2)
        #expect(summary.savedToPhotos == 2)
        #expect(summary.deletableIDs == ["a", "b"])
    }

    @Test func anEmptyRunSavesNothing() {
        let summary = BatchSummary(jobs: [])
        #expect(summary.beforeBytes == 0)
        #expect(summary.savedBytes == 0)
        #expect(summary.savedFraction == 0)
        #expect(summary.deletableIDs.isEmpty)
    }

    @Test func videosKeptAsTheyWereCountOnBothSides() {
        let summary = BatchSummary(jobs: [Self.job(.notSmaller), Self.job(.done(bytes: 40_000_000, saved: true))])
        #expect(summary.beforeBytes == 200_000_000)
        #expect(summary.afterBytes == 140_000_000)
        #expect(summary.savedFraction == 0.3)
        #expect(summary.notSmaller == 1)
    }

    @Test func failedCancelledAndUnfinishedVideosAreLeftOutOfTheSizes() {
        let jobs = [Self.job(.failed), Self.job(.unreadable), Self.job(.cancelled), Self.job(.waiting), Self.job(.compressing(0.5)), Self.job(.loading)]
        let summary = BatchSummary(jobs: jobs)
        #expect(summary.beforeBytes == 0)
        #expect(summary.afterBytes == 0)
        #expect(summary.failed == 2)
        #expect(summary.cancelled == 1)
        #expect(summary.compressed == 0)
    }

    @Test func onlyOriginalsFromPhotosWithACopyInPhotosCanBeDeleted() {
        let jobs = [
            Self.job(.done(bytes: 1, saved: true), assetID: "photos"),
            Self.job(.done(bytes: 1, saved: false), assetID: "unsaved"),
            Self.job(.done(bytes: 1, saved: true), assetID: nil),
            Self.job(.notSmaller, assetID: "light"),
            Self.job(.failed, assetID: "failed"),
        ]
        #expect(BatchSummary(jobs: jobs).deletableIDs == ["photos"])
    }

    @Test(arguments: [Int64(-5), 0, 100_000_000, 999_000_000_000])
    func aCopyIsNeverCountedHeavierThanItsOriginalNorNegative(bytes: Int64) {
        let summary = BatchSummary(jobs: [Self.job(.done(bytes: bytes, saved: true))])
        #expect(summary.afterBytes >= 0)
        #expect(summary.afterBytes <= summary.beforeBytes)
        #expect(summary.savedBytes >= 0)
        #expect((0...1).contains(summary.savedFraction))
    }

    @Test func aJobWithoutASourceCountsZero() {
        let job = VideoJob(assetID: "x", state: .done(bytes: 10, saved: true))
        let summary = BatchSummary(jobs: [job])
        #expect(summary.beforeBytes == 0)
        #expect(summary.afterBytes == 0)
        #expect(summary.compressed == 1)
    }
}
