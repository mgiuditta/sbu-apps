import Foundation
import Testing
@testable import SbuClean

struct CleanModelTests {
    private let directory = Fixture.directory()

    private func library() -> FakeLibrary {
        let start = Fixture.date(10, 1)
        let items = [
            Fixture.photo("burst-1", on: start.addingTimeInterval(2)),
            Fixture.photo("burst-0", on: start),
            Fixture.photo("screen", on: Fixture.date(9, 20), screenshot: true),
            Fixture.video("film", on: Fixture.date(9, 1)),
        ].map { item in
            var item = item
            item.size = nil
            return item
        }
        let sizes = [
            "burst-1": ItemSize(bytes: 3_000_000),
            "burst-0": ItemSize(bytes: 3_500_000),
            "screen": ItemSize(bytes: 1_000_000),
            "film": ItemSize(bytes: 90_000_000),
        ]
        let analyses = [
            "burst-0": ImageAnalysis(featurePrint: Fixture.print(axis: 0), sharpness: 600),
            "burst-1": ImageAnalysis(featurePrint: Fixture.print(axis: 0, offset: 0.2), sharpness: 100),
            "screen": ImageAnalysis(featurePrint: Fixture.print(axis: 4)),
        ]
        return FakeLibrary(items: items, sizes: sizes, analyses: analyses)
    }

    private func loadedModel(_ library: FakeLibrary) async -> CleanModel {
        let model = CleanModel(library: library, directory: directory, now: { Fixture.date(10, 13) }, readStorage: { nil })
        await model.reload()
        await waitForScan(model)
        return model
    }

    private func waitForScan(_ model: CleanModel) async {
        await model.waitForScan()
    }

    @Test func loadingMeasuresEverythingAndFindsTheBurst() async {
        let model = await loadedModel(library())

        #expect(model.items.count == 4)
        #expect(model.unmeasuredCount == 0)
        #expect(model.scan == .finished)
        #expect(model.groups == [PhotoGroup(kind: .similar, members: ["burst-0", "burst-1"])])
        // The blurred copy, preselected, plus the screenshot.
        #expect(model.freeableBytes == 4_000_000)
    }

    @Test func sizesAndAnalysesAreCachedForTheNextLaunch() async {
        let fake = library()
        _ = await loadedModel(fake)
        let measuredBefore = fake.measured.count
        let analysedBefore = fake.analyzed.count

        let again = await loadedModel(fake)

        #expect(again.groups.count == 1)
        #expect(fake.measured.count == measuredBefore)
        #expect(fake.analyzed.count == analysedBefore)
    }

    @Test func aRescanAnalysesOnlyNewPhotos() async {
        let fake = library()
        let model = await loadedModel(fake)
        fake.update { contents in
            contents.items.insert(Fixture.photo("new", on: Fixture.date(10, 12)), at: 0)
            contents.analyses["new"] = ImageAnalysis(featurePrint: Fixture.print(axis: 6))
        }

        await model.reload()
        await waitForScan(model)

        #expect(fake.analyzed.filter { $0 == "new" }.count == 1)
        #expect(fake.analyzed.filter { $0 == "burst-0" }.count == 1)
    }

    @Test func decisionsSurviveARestart() async {
        let fake = library()
        let model = await loadedModel(fake)
        model.decide(.trash, on: "burst-1")
        model.decide(.keepForever, on: "screen")

        let restarted = await loadedModel(fake)

        #expect(restarted.state.trash == ["burst-1"])
        #expect(restarted.state.keepForever == ["screen"])
        #expect(restarted.items(in: .screenshots).isEmpty)
    }

    @Test func deletingTheBinRecordsTheFreedSpace() async throws {
        let fake = library()
        let model = await loadedModel(fake)
        model.moveToTrash(["film", "burst-1"])

        let result = try await model.deleteTrash()

        #expect(result.count == 2)
        #expect(result.bytes == 93_000_000)
        #expect(fake.deleted == ["film", "burst-1"])
        #expect(model.state.trash.isEmpty)
        #expect(model.state.freed.totalBytes == 93_000_000)
        #expect(model.items.map(\.id) == ["burst-0", "screen"])
        #expect(model.groups.isEmpty)
    }

    @Test func refusingTheSystemDialogKeepsTheBin() async {
        let fake = library()
        let model = await loadedModel(fake)
        model.moveToTrash(["film"])
        fake.update { $0.refusesDeletion = true }

        await #expect(throws: CocoaError.self) {
            try await model.deleteTrash()
        }
        #expect(model.state.trash == ["film"])
        #expect(model.state.freed.totalCount == 0)
    }

    @Test func undoRestoresThePreviousDecision() async {
        let model = await loadedModel(library())
        model.decide(.later, on: "film")
        let previous = model.decide(.trash, on: "film")

        model.decide(previous, on: "film")

        #expect(model.state.decision(for: "film") == .later)
    }

    @Test func restoringFromTheBinOpensTheItemAgain() async {
        let model = await loadedModel(library())
        model.moveToTrash(["film"])
        model.restore("film")
        #expect(model.state.decision(for: "film") == nil)
        #expect(model.trashBytes == 0)
    }

    @Test func withoutAccessNothingIsRead() async {
        let fake = FakeLibrary(items: [Fixture.photo("a")], access: .denied)
        let model = CleanModel(library: fake, directory: directory, readStorage: { nil })

        await model.reload()

        #expect(model.access == .denied)
        #expect(model.items.isEmpty)
        #expect(!model.hasLoaded)
    }

    @Test func requestingAccessGrantsIt() async {
        let fake = FakeLibrary(access: .notDetermined)
        let model = CleanModel(library: fake, directory: directory, readStorage: { nil })

        await model.requestAccess()

        #expect(model.access == .full)
    }
}
