import Foundation
import Testing
@testable import SbuShrink

/// The whole flow on fakes: pick, read, settings, run, result, originals.
@MainActor
struct ShrinkModelTests {
    private let defaults: UserDefaults

    init() {
        let suite = "test-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.removePersistentDomain(forName: suite)
    }

    private func model(
        compressor: FakeCompressor = FakeCompressor(),
        library: FakeLibrary = FakeLibrary(),
        probe: @escaping ShrinkModel.Probe = FakeVideos.probe()
    ) -> ShrinkModel {
        ShrinkModel(compressor: compressor, library: library, preferences: Preferences(defaults: defaults), probe: probe)
    }

    /// Picks and waits until every video is read.
    private func picked(_ names: [String], into model: ShrinkModel) async throws {
        model.pick(names.map { FakeVideos.pending($0) })
        try await waitUntil { !model.isLoading }
    }

    private func ran(_ model: ShrinkModel) async throws {
        model.compress()
        try await waitUntil { model.stage != .compressing }
    }

    private func waitUntil(_ condition: () -> Bool, sourceLocation: SourceLocation = #_sourceLocation) async throws {
        for _ in 0..<500 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(condition(), "timed out", sourceLocation: sourceLocation)
    }

    // MARK: - Pick and read

    @Test func startsOnThePickWithNothing() {
        let model = model()
        #expect(model.stage == .picking)
        #expect(model.jobs.isEmpty)
        #expect(!model.canCompress)
        #expect(model.totalBytes == 0)
        #expect(model.estimatedBytes == 0)
        #expect(model.estimatedSavedFraction == 0)
        #expect(model.targetFit == nil)
    }

    @Test func anEmptyPickChangesNothing() {
        let model = model()
        model.pick([])
        #expect(model.stage == .picking)
        #expect(model.jobs.isEmpty)
    }

    @Test func aPickOpensTheSettingsAndReadsEveryVideoInOrder() async throws {
        let model = model()
        model.pick(["A.MOV", "B.MOV", "C.MOV"].map { FakeVideos.pending($0) })
        #expect(model.stage == .settings)
        #expect(model.jobs.count == 3)
        #expect(!model.canCompress)

        try await waitUntil { !model.isLoading }
        #expect(model.jobs.map(\.name) == ["A.MOV", "B.MOV", "C.MOV"])
        #expect(model.jobs.allSatisfy { $0.state == .waiting })
        #expect(model.jobs.map(\.assetID) == ["asset/A.MOV", "asset/B.MOV", "asset/C.MOV"])
        #expect(model.canCompress)
    }

    @Test func videosThatCannotBeReadStayOutOfTheBatch() async throws {
        let model = model()
        try await picked(["A.MOV", "BAD.MOV", "NOPE.MOV"], into: model)
        #expect(model.unreadableCount == 2)
        #expect(model.readyJobs.map(\.name) == ["A.MOV"])
        #expect(model.totalBytes == 128_460_000)
        #expect(model.canCompress)
    }

    @Test func onlyUnreadableVideosCannotBeCompressed() async throws {
        let model = model()
        try await picked(["BAD.MOV", "NOPE.MOV"], into: model)
        #expect(model.readyJobs.isEmpty)
        #expect(!model.canCompress)
        model.compress()
        #expect(model.stage == .settings)
    }

    @Test func totalsAndEstimateAddUpTheReadyVideos() async throws {
        let model = model()
        try await picked(["A.MOV", "B.MOV"], into: model)
        let plan = try #require(model.plan(for: model.jobs[0]))
        #expect(model.totalBytes == 2 * 128_460_000)
        #expect(model.estimatedBytes == 2 * plan.estimatedBytes)
        #expect((0.75...0.9).contains(model.estimatedSavedFraction))
    }

    @Test func theEstimateFollowsTheSettings() async throws {
        let model = model()
        try await picked(["A.MOV"], into: model)
        let suggested = model.estimatedBytes
        model.settings.dimensionPercent = 50
        #expect(model.estimatedBytes < suggested)
        model.settings.dimensionPercent = 100
        model.settings.qualityPercent = 100
        #expect(model.estimatedBytes > suggested)
    }

    @Test(arguments: [(1.0, TargetFit.tooSmall), (10, .fits), (500, .alreadySmaller)])
    func targetFitIsTheWorstOfTheVideos(megabytes: Double, expected: TargetFit) async throws {
        let model = model()
        try await picked(["A.MOV", "B.MOV"], into: model)
        model.settings.targetMegabytes = megabytes
        #expect(model.targetFit == expected)
        model.settings.targetMegabytes = nil
        #expect(model.targetFit == nil)
    }

    @Test func discardGoesBackToThePickAndForgetsTheBatch() async throws {
        let model = model()
        try await picked(["A.MOV"], into: model)
        model.discard()
        #expect(model.stage == .picking)
        #expect(model.jobs.isEmpty)
    }

    @Test func aNewPickReplacesTheBatch() async throws {
        let model = model()
        try await picked(["A.MOV", "B.MOV"], into: model)
        try await picked(["C.MOV"], into: model)
        #expect(model.jobs.map(\.name) == ["C.MOV"])
    }

    // MARK: - Run

    @Test func aRunCompressesEveryVideoAndSavesItInTheAlbum() async throws {
        let compressor = FakeCompressor(["A.MOV": .succeed(20_000_000), "B.MOV": .succeed(30_000_000)])
        let library = FakeLibrary()
        let model = model(compressor: compressor, library: library)
        try await picked(["A.MOV", "B.MOV"], into: model)
        try await ran(model)

        #expect(model.stage == .done)
        #expect(model.jobs.map(\.state) == [.done(bytes: 20_000_000, saved: true), .done(bytes: 30_000_000, saved: true)])
        #expect(library.calls.saved.map(\.original) == ["asset/A.MOV", "asset/B.MOV"])
        #expect(library.calls.saved.allSatisfy { $0.toAlbum })
        #expect(model.jobs.allSatisfy { $0.output != nil })
        #expect(model.progress.fraction == 1)
        let summary = model.summary
        #expect(summary.beforeBytes == 2 * 128_460_000)
        #expect(summary.afterBytes == 50_000_000)
        #expect(summary.savedBytes == 2 * 128_460_000 - 50_000_000)
        #expect(summary.compressed == 2)
        #expect(summary.savedToPhotos == 2)
        #expect(summary.deletableIDs == ["asset/A.MOV", "asset/B.MOV"])
    }

    @Test func theAlbumSwitchIsHonoured() async throws {
        let library = FakeLibrary()
        let model = model(library: library)
        model.savesToAlbum = false
        try await picked(["A.MOV"], into: model)
        try await ran(model)
        #expect(library.calls.saved.map(\.toAlbum) == [false])
    }

    @Test func everyVideoGetsTheSettingsOfTheMomentCompressWasTapped() async throws {
        let compressor = FakeCompressor()
        let model = model(compressor: compressor)
        try await picked(["A.MOV"], into: model)
        model.settings = CompressionSettings(frameRate: 30, dimensionPercent: 50, codec: .hevc, removesAudio: true, convertsToMP4: true)
        try await ran(model)
        let plan = try #require(compressor.receivedPlans["A.MOV"])
        #expect(plan.size == PixelSize(width: 960, height: 540))
        #expect(plan.codec == .hevc)
        #expect(plan.audioBitsPerSecond == 0)
        #expect(plan.format == .mp4)
    }

    @Test func aCopyThatIsNotLighterIsDroppedAndTheOriginalStays() async throws {
        let library = FakeLibrary()
        let compressor = FakeCompressor(["A.MOV": .succeed(128_460_000), "B.MOV": .succeed(200_000_000), "C.MOV": .succeed(0)])
        let model = model(compressor: compressor, library: library)
        try await picked(["A.MOV", "B.MOV", "C.MOV"], into: model)
        try await ran(model)

        #expect(model.jobs.map(\.state) == [.notSmaller, .notSmaller, .notSmaller])
        #expect(library.calls.saved.isEmpty)
        #expect(model.stage == .done)
        let summary = model.summary
        #expect(summary.notSmaller == 3)
        #expect(summary.savedBytes == 0)
        #expect(summary.deletableIDs.isEmpty)
    }

    @Test func aFailingVideoDoesNotStopTheQueue() async throws {
        let compressor = FakeCompressor(["B.MOV": .fail])
        let model = model(compressor: compressor)
        try await picked(["A.MOV", "B.MOV", "C.MOV"], into: model)
        try await ran(model)

        #expect(model.jobs[0].state.isFinished && model.jobs[0].state != .failed)
        #expect(model.jobs[1].state == .failed)
        #expect(model.jobs[2].state.isFinished && model.jobs[2].state != .failed)
        #expect(model.summary.compressed == 2)
        #expect(model.summary.failed == 1)
        #expect(model.stage == .done)
    }

    @Test func aRunWhereEverythingFailsStillShowsTheResult() async throws {
        let model = model(compressor: FakeCompressor(["A.MOV": .fail]))
        try await picked(["A.MOV"], into: model)
        try await ran(model)
        #expect(model.stage == .done)
        #expect(model.summary.compressed == 0)
        #expect(model.summary.failed == 1)
    }

    @Test func unreadableVideosAreNotCountedAsAFinishedRun() async throws {
        let model = model(compressor: FakeCompressor(["A.MOV": .hang]))
        try await picked(["BAD.MOV", "A.MOV"], into: model)
        model.compress()
        try await waitUntil { model.jobs.contains { if case .compressing = $0.state { true } else { false } } }
        model.cancel()
        try await waitUntil { model.stage != .compressing }
        // Only the unreadable one is "failed": nothing ran, so back to the settings.
        #expect(model.stage == .settings)
    }

    @Test func cancellingKeepsWhatIsDoneAndStopsTheRest() async throws {
        let library = FakeLibrary()
        let compressor = FakeCompressor(["A.MOV": .succeed(10_000_000), "B.MOV": .hang])
        let model = model(compressor: compressor, library: library)
        try await picked(["A.MOV", "B.MOV", "C.MOV"], into: model)
        model.compress()
        try await waitUntil { model.jobs[1].state != .waiting }
        #expect(model.progress.current == 2)
        #expect(model.progress.total == 3)

        model.cancel()
        try await waitUntil { model.stage != .compressing }

        #expect(model.stage == .done)
        #expect(model.jobs.map(\.state) == [.done(bytes: 10_000_000, saved: true), .cancelled, .cancelled])
        #expect(library.calls.saved.count == 1)
        #expect(compressor.receivedPlans["C.MOV"] == nil)
        #expect(model.summary.cancelled == 2)
    }

    @Test func cancellingBeforeAnythingIsDoneGoesBackToTheSettings() async throws {
        let model = model(compressor: FakeCompressor(["A.MOV": .hang]))
        try await picked(["A.MOV", "B.MOV"], into: model)
        model.compress()
        try await waitUntil { model.jobs[0].state != .waiting }
        model.cancel()
        try await waitUntil { model.stage != .compressing }

        #expect(model.stage == .settings)
        #expect(model.jobs.allSatisfy { $0.state == .waiting })
        #expect(model.canCompress)
    }

    @Test func compressingTwiceDoesNotStartASecondRun() async throws {
        let compressor = FakeCompressor(["A.MOV": .hang])
        let model = model(compressor: compressor)
        try await picked(["A.MOV"], into: model)
        model.compress()
        #expect(!model.canCompress)
        model.compress()
        model.cancel()
        try await waitUntil { model.stage != .compressing }
        #expect(model.stage == .settings)
    }

    // MARK: - Photos permission

    @Test func theFirstRunAsksForPhotos() async throws {
        let library = FakeLibrary(access: .notDetermined, granted: .full)
        let model = model(library: library)
        #expect(model.access == .notDetermined)
        try await picked(["A.MOV"], into: model)
        try await ran(model)
        #expect(library.calls.requests == 1)
        #expect(model.access == .full)
        #expect(model.summary.savedToPhotos == 1)
    }

    @Test(arguments: [LibraryAccess.denied, .notDetermined])
    func withoutPhotosTheCopiesAreKeptForSharing(access: LibraryAccess) async throws {
        let library = FakeLibrary(access: access, granted: .denied)
        let model = model(library: library)
        try await picked(["A.MOV", "B.MOV"], into: model)
        try await ran(model)

        #expect(library.calls.saved.isEmpty)
        #expect(model.summary.compressed == 2)
        #expect(model.summary.savedToPhotos == 0)
        #expect(model.summary.deletableIDs.isEmpty)
        #expect(model.jobs.allSatisfy { $0.output != nil })
    }

    @Test func limitedAccessStillSaves() async throws {
        let library = FakeLibrary(access: .limited)
        let model = model(library: library)
        try await picked(["A.MOV"], into: model)
        try await ran(model)
        #expect(model.summary.savedToPhotos == 1)
    }

    @Test func aSaveThatFailsLeavesTheCopyUnsavedAndTheOriginalSafe() async throws {
        let model = model(library: FakeLibrary(failsSave: true))
        try await picked(["A.MOV"], into: model)
        try await ran(model)
        #expect(model.summary.compressed == 1)
        #expect(model.summary.savedToPhotos == 0)
        #expect(model.summary.deletableIDs.isEmpty)
    }

    @Test func videosFromFilesHaveNoOriginalToDelete() async throws {
        let model = model()
        model.pick([FakeVideos.pending("A.MOV", fromFiles: true), FakeVideos.pending("B.MOV")])
        try await waitUntil { !model.isLoading }
        try await ran(model)
        #expect(model.summary.savedToPhotos == 2)
        #expect(model.summary.deletableIDs == ["asset/B.MOV"])
    }

    // MARK: - Originals

    @Test func deletingRemovesOnlyTheOriginalsWithACopyInPhotos() async throws {
        let library = FakeLibrary()
        let model = model(compressor: FakeCompressor(["B.MOV": .fail]), library: library)
        try await picked(["A.MOV", "B.MOV", "C.MOV"], into: model)
        try await ran(model)
        await model.deleteOriginals()
        #expect(library.calls.deleted == ["asset/A.MOV", "asset/C.MOV"])
        #expect(model.deletion == .deleted(2))
    }

    @Test func iOSCanDeleteFewerThanAsked() async throws {
        let model = model(library: FakeLibrary(deletes: 1))
        try await picked(["A.MOV", "B.MOV"], into: model)
        try await ran(model)
        await model.deleteOriginals()
        #expect(model.deletion == .deleted(1))
    }

    @Test(arguments: [(LibraryError.cancelled, Deletion.idle), (.saveFailed, .failed), (.denied, .failed)])
    func aRefusedOrFailedDeletionSaysSo(error: LibraryError, expected: Deletion) async throws {
        let model = model(library: FakeLibrary(deleteError: error))
        try await picked(["A.MOV"], into: model)
        try await ran(model)
        await model.deleteOriginals()
        #expect(model.deletion == expected)
    }

    @Test func nothingToDeleteAsksNothing() async throws {
        let library = FakeLibrary()
        let model = model(library: library)
        await model.deleteOriginals()
        #expect(model.deletion == .idle)
        #expect(library.calls.deleted.isEmpty)
    }

    @Test func finishGoesBackToThePickWithAFreshBatch() async throws {
        let model = model()
        try await picked(["A.MOV"], into: model)
        model.finish()
        // Not done yet: finish does nothing.
        #expect(model.stage == .settings)
        try await ran(model)
        await model.deleteOriginals()
        model.finish()
        #expect(model.stage == .picking)
        #expect(model.jobs.isEmpty)
        #expect(model.deletion == .idle)
    }

    // MARK: - Preferences

    @Test func settingsAndAlbumAreRemembered() {
        let first = model()
        first.settings = CompressionSettings(frameRate: 30, dimensionPercent: 50, targetMegabytes: 8)
        first.savesToAlbum = false
        let second = model()
        #expect(second.settings == CompressionSettings(frameRate: 30, dimensionPercent: 50, targetMegabytes: 8))
        #expect(!second.savesToAlbum)
    }

    @Test func restoringSuggestedSettingsResetsEverything() {
        let model = model()
        model.settings = CompressionSettings(frameRate: 60, dimensionPercent: 10, qualityPercent: 100, targetMegabytes: 3, codec: .hevc, removesAudio: true, convertsToMP4: true)
        model.restoreSuggestedSettings()
        #expect(model.settings == CompressionSettings())
        #expect(model.savesToAlbum)
    }
}
