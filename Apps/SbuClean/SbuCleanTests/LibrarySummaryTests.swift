import Foundation
import Testing
@testable import SbuClean

struct LibrarySummaryTests {
    private let now = Fixture.date(10, 13)

    private func summary(_ items: [MediaItem], state: CleanState = CleanState(), groups: [PhotoGroup] = []) -> LibrarySummary {
        let index = LibraryIndex(indexing: items)
        return LibrarySummary(items: index.items, monthOf: index.monthOf, state: state, groups: groups, selection: GroupSelection(), now: now)
    }

    @Test func countsEachCategoryWithItsSize() {
        let live = MediaItem(id: "live", creationDate: Fixture.date(9, 1), kind: .photo, isLivePhoto: true,
                             size: ItemSize(bytes: 5_000_000, pairedVideoBytes: 2_000_000))
        let result = summary([
            Fixture.photo("screen", on: Fixture.date(9, 1), bytes: 10, screenshot: true),
            Fixture.video("recording", on: Fixture.date(9, 1), bytes: 20, recording: true),
            Fixture.video("film", on: Fixture.date(9, 1), bytes: 30),
            live,
        ])

        #expect(result.screenshots == LibrarySummary.Category(count: 1, bytes: 10))
        #expect(result.screenRecordings == LibrarySummary.Category(count: 1, bytes: 20))
        #expect(result.videos == LibrarySummary.Category(count: 2, bytes: 50))
        #expect(result.livePhotos == LibrarySummary.Category(count: 1, bytes: 2_000_000))
        #expect(result.itemCount == 4)
    }

    @Test func agreesWithTheFreeableSpaceAndTheQueues() {
        let items = [
            Fixture.photo("recent", on: Fixture.date(10, 10), bytes: 7),
            Fixture.photo("best", on: Fixture.date(9, 20), bytes: 60),
            Fixture.photo("copy", on: Fixture.date(9, 20), bytes: 50),
            Fixture.photo("screen", on: Fixture.date(8, 2), bytes: 20, screenshot: true),
            Fixture.photo("this-day", on: Fixture.date(10, 13, year: 2024), bytes: 1),
            Fixture.photo("kept", on: Fixture.date(10, 11), bytes: 3),
        ]
        var state = CleanState()
        state.set(.trash, for: "recent")
        state.set(.keep, for: "kept")
        let groups = [PhotoGroup(kind: .duplicate, members: ["best", "copy"])]

        let result = summary(items, state: state, groups: groups)
        let queues = QueueBuilder(items: items, state: state, now: now)

        #expect(result.freeableBytes == FreeableSpace.bytes(of: FreeableSpace.ids(items: items, state: state, groups: groups, selection: GroupSelection()),
                                                             in: Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })))
        #expect(result.freeableBytes == 77)
        #expect(result.selectedGroupBytes == 50)
        #expect(result.recentCount == queues.recentItems.count)
        #expect(result.onThisDayCount == queues.onThisDayItems.count)
        #expect(result.onThisDayCount == 1)
        #expect(result.months == queues.months())
    }

    @Test func itemsKeptForeverCountNowhere() {
        var state = CleanState()
        state.set(.keepForever, for: "screen")
        let result = summary([Fixture.photo("screen", on: Fixture.date(9, 1), bytes: 10, screenshot: true)], state: state)

        #expect(result.screenshots.count == 0)
        #expect(result.freeableBytes == 0)
    }
}
