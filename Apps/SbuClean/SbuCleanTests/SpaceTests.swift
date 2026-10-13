import Foundation
import Testing
@testable import SbuClean

struct SpaceTests {
    @Test(arguments: [
        (Int64(0), "0", "MB"),
        (Int64(350_400_000), "350", "MB"),
        (Int64(999_000_000), "999", "MB"),
        (Int64(1_000_000_000), "1.0", "GB"),
        (Int64(1_260_000_000), "1.3", "GB"),
        (Int64(23_400_000_000), "23", "GB"),
    ])
    func figureUsesMegabytesThenGigabytes(bytes: Int64, number: String, unit: String) {
        let figure = SpaceFigure(bytes: bytes)
        #expect(figure.unit == unit)
        #expect(figure.format.locale(Locale(identifier: "en_US")).format(figure.value) == number)
    }

    @Test func italianUsesTheDecimalComma() {
        let figure = SpaceFigure(bytes: 1_260_000_000)
        #expect(figure.format.locale(Locale(identifier: "it_IT")).format(figure.value) == "1,3")
    }

    @Test func freeableCountsEachItemOnceAndNeverWhatIsKeptForever() {
        let items = [
            Fixture.photo("shot", bytes: 10),
            Fixture.photo("screen", bytes: 20, screenshot: true),
            Fixture.video("recording", bytes: 30, recording: true),
            Fixture.video("film", bytes: 40),
            Fixture.photo("copy", bytes: 50),
            Fixture.photo("best", bytes: 60),
            Fixture.photo("safe-screen", bytes: 70, screenshot: true),
        ]
        var state = CleanState()
        state.addToTrash(["shot", "screen"])
        state.set(.keepForever, for: "safe-screen")
        let groups = [PhotoGroup(kind: .duplicate, members: ["best", "copy"])]

        let ids = FreeableSpace.ids(items: items, state: state, groups: groups, selection: GroupSelection())

        #expect(ids == ["shot", "screen", "recording", "copy"])
        let byID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        #expect(FreeableSpace.bytes(of: ids, in: byID) == 110)
    }

    @Test func groupSelectionStartsWithEveryCopyButTheBest() {
        let group = PhotoGroup(kind: .similar, members: ["best", "a", "b"])
        var selection = GroupSelection()
        #expect(selection.selected(in: [group]) == ["a", "b"])

        selection.toggle("best", in: group)
        selection.toggle("a", in: group)
        #expect(selection.selected(in: [group]) == ["best", "b"])
        #expect(!selection.areAllCopiesSelected(in: group))

        selection.toggleAllCopies(in: group)
        #expect(selection.selected(in: [group]) == ["a", "b"])
        selection.toggleAllCopies(in: group)
        #expect(selection.selected(in: [group]).isEmpty)
    }

    @Test(arguments: [CompressionQuality.low, .medium, .high])
    func compressionEstimateNeverExceedsTheOriginal(quality: CompressionQuality) {
        #expect(quality.estimatedBytes(duration: 60, originalBytes: 1_000) == 1_000)
        let estimate = quality.estimatedBytes(duration: 60, originalBytes: 1_000_000_000)
        #expect(estimate == Int64(quality.bitsPerSecond / 8 * 60))
    }

    @Test func storageUsedIsTotalMinusAvailable() {
        let storage = DeviceStorage(totalBytes: 128, availableBytes: 32)
        #expect(storage.usedBytes == 96)
        #expect(storage.usedFraction == 0.75)
    }
}
