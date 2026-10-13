import Foundation
import Testing
@testable import SbuClean

/// Grouping on hand-made prints, where every distance is known.
struct SimilarityGrouperTests {
    private let grouper = SimilarityGrouper()

    @Test func copiesFarApartInTimeAreDuplicates() {
        let items = [
            Fixture.photo("2024", on: Fixture.date(3, 1, year: 2024)),
            Fixture.photo("2026", on: Fixture.date(3, 1)),
            Fixture.photo("other", on: Fixture.date(3, 1)),
        ]
        let analyses = [
            "2024": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
            "2026": ImageAnalysis(featurePrint: Fixture.print(axis: 0, offset: 0.05)),
            "other": ImageAnalysis(featurePrint: Fixture.print(axis: 3)),
        ]

        let groups = grouper.groups(of: items, analyses: analyses)

        #expect(groups.count == 1)
        #expect(groups.first?.kind == .duplicate)
        #expect(Set(groups.first?.members ?? []) == ["2024", "2026"])
    }

    @Test func copiesFarApartWithDifferentSizesAreNotCompared() {
        // Comparing every pair of a big library is out of reach: far apart in time, only an
        // identical size makes two photos candidates.
        let items = [
            Fixture.photo("2024", on: Fixture.date(3, 1, year: 2024), bytes: 2_000_000),
            Fixture.photo("2026", on: Fixture.date(3, 1), bytes: 1_000_000),
        ]
        let analyses = [
            "2024": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
            "2026": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
        ]

        #expect(grouper.groups(of: items, analyses: analyses).isEmpty)
    }

    @Test func copiesTheSameDayAreDuplicatesWhateverTheirSize() {
        let items = [
            Fixture.photo("morning", on: Fixture.date(3, 1, hour: 8), bytes: 2_000_000),
            Fixture.photo("evening", on: Fixture.date(3, 1, hour: 20), bytes: 1_000_000),
        ]
        let analyses = [
            "morning": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
            "evening": ImageAnalysis(featurePrint: Fixture.print(axis: 0, offset: 0.05)),
        ]

        #expect(grouper.groups(of: items, analyses: analyses).map(\.kind) == [.duplicate])
    }

    @Test func aHugeLibraryGroupsQuickly() {
        // 20,000 photos, one every ten minutes, all different: the windows keep it linear.
        let start = Fixture.date(1, 1, year: 2020)
        var items: [MediaItem] = []
        var analyses: [String: ImageAnalysis] = [:]
        var generator = SeededGenerator(seed: 3)
        for index in 0..<20_000 {
            let id = "photo-\(index)"
            items.append(Fixture.photo(id, on: start.addingTimeInterval(Double(index) * 600), bytes: Int64(1_000_000 + index)))
            analyses[id] = ImageAnalysis(featurePrint: (0..<64).map { _ in Float.random(in: -1...1, using: &generator) })
        }

        let clock = ContinuousClock()
        let elapsed = clock.measure {
            _ = grouper.groups(of: items, analyses: analyses)
        }

        #expect(elapsed < .seconds(10))
    }

    @Test func lookalikesTakenCloseInTimeAreSimilar() {
        let start = Fixture.date(6, 10)
        let items = [
            Fixture.photo("first", on: start),
            Fixture.photo("second", on: start.addingTimeInterval(60)),
        ]
        let analyses = [
            "first": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
            "second": ImageAnalysis(featurePrint: Fixture.print(axis: 0, offset: 0.2)),
        ]

        let groups = grouper.groups(of: items, analyses: analyses)

        #expect(groups.map(\.kind) == [.similar])
    }

    @Test func lookalikesTakenHoursApartStayApart() {
        let start = Fixture.date(6, 10)
        let items = [
            Fixture.photo("morning", on: start),
            Fixture.photo("evening", on: start.addingTimeInterval(6 * 3600)),
        ]
        let analyses = [
            "morning": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
            "evening": ImageAnalysis(featurePrint: Fixture.print(axis: 0, offset: 0.2)),
        ]

        #expect(grouper.groups(of: items, analyses: analyses).isEmpty)
    }

    @Test func aBurstWithOneBlurredShotIsOneSimilarGroup() {
        let start = Fixture.date(7, 1)
        let items = (0..<3).map { Fixture.photo("shot-\($0)", on: start.addingTimeInterval(Double($0) * 2)) }
        let analyses = [
            "shot-0": ImageAnalysis(featurePrint: Fixture.print(axis: 1), sharpness: 500),
            "shot-1": ImageAnalysis(featurePrint: Fixture.print(axis: 1, offset: 0.03), sharpness: 520),
            "shot-2": ImageAnalysis(featurePrint: Fixture.print(axis: 1, offset: 0.22), sharpness: 90),
        ]

        let groups = grouper.groups(of: items, analyses: analyses)

        #expect(groups.count == 1)
        #expect(groups.first?.kind == .similar)
        #expect(groups.first?.members.count == 3)
        #expect(groups.first?.best != "shot-2")
    }

    @Test func screenshotsAreNeverSimilarOnlyDuplicate() {
        let start = Fixture.date(8, 1)
        let items = [
            Fixture.photo("screen-a", on: start, screenshot: true),
            Fixture.photo("screen-b", on: start.addingTimeInterval(30), screenshot: true),
            Fixture.photo("screen-a-again", on: start.addingTimeInterval(90), screenshot: true),
        ]
        let analyses = [
            "screen-a": ImageAnalysis(featurePrint: Fixture.print(axis: 2)),
            "screen-b": ImageAnalysis(featurePrint: Fixture.print(axis: 2, offset: 0.2)),
            "screen-a-again": ImageAnalysis(featurePrint: Fixture.print(axis: 2)),
        ]

        let groups = grouper.groups(of: items, analyses: analyses)

        #expect(groups.count == 1)
        #expect(groups.first?.kind == .duplicate)
        #expect(Set(groups.first?.members ?? []) == ["screen-a", "screen-a-again"])
    }

    @Test func videosAndUnanalysedPhotosAreLeftOut() {
        let items = [
            Fixture.photo("analysed", on: Fixture.date(1, 1)),
            Fixture.photo("waiting", on: Fixture.date(1, 1)),
            Fixture.video("video", on: Fixture.date(1, 1)),
        ]
        let analyses = [
            "analysed": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
            "video": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
        ]

        #expect(grouper.groups(of: items, analyses: analyses).isEmpty)
    }

    @Test func groupsComeNewestFirstDuplicatesBeforeSimilar() {
        let items = [
            Fixture.photo("old-a", on: Fixture.date(1, 1)),
            Fixture.photo("old-b", on: Fixture.date(1, 1, minute: 1)),
            Fixture.photo("new-a", on: Fixture.date(9, 1)),
            Fixture.photo("new-b", on: Fixture.date(9, 1, minute: 1)),
            Fixture.photo("dup-a", on: Fixture.date(2, 1)),
            Fixture.photo("dup-b", on: Fixture.date(4, 1)),
        ]
        let analyses = [
            "old-a": ImageAnalysis(featurePrint: Fixture.print(axis: 0)),
            "old-b": ImageAnalysis(featurePrint: Fixture.print(axis: 0, offset: 0.2)),
            "new-a": ImageAnalysis(featurePrint: Fixture.print(axis: 2)),
            "new-b": ImageAnalysis(featurePrint: Fixture.print(axis: 2, offset: 0.2)),
            "dup-a": ImageAnalysis(featurePrint: Fixture.print(axis: 5)),
            "dup-b": ImageAnalysis(featurePrint: Fixture.print(axis: 5)),
        ]

        let groups = grouper.groups(of: items, analyses: analyses)

        #expect(groups.map(\.kind) == [.duplicate, .similar, .similar])
        #expect(groups[1].members.contains("new-a"))
        #expect(groups[2].members.contains("old-a"))
    }
}
