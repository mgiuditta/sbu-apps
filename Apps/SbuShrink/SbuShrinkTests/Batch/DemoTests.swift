import Foundation
import Testing
@testable import SbuShrink

/// The demo the UI tests and the screenshots stand on.
@MainActor
struct DemoTests {
    @Test(arguments: [0, 1, 3, 5, 9, -2])
    func demoNamesAreTheFirstRegularOnes(count: Int) {
        let names = DemoVideos.names(count: count, scenario: nil)
        #expect(names.count == min(max(count, 0), 5))
        #expect(names.allSatisfy { DemoVideos.sources[$0] != nil })
    }

    @Test func theMixedScenarioAddsALightAndABrokenVideo() {
        let names = DemoVideos.names(count: 2, scenario: "mixed")
        #expect(names.suffix(2) == ["IMG_0907.MP4", "IMG_BROKEN.MOV"])
    }

    @Test func everyDemoSourceIsUsable() {
        #expect(DemoVideos.sources.values.allSatisfy { $0.isUsable })
    }

    @Test func theMixedDemoEndsWithOneOfEachOutcome() async throws {
        let suite = "demo-\(UUID().uuidString)"
        let model = ShrinkModel(
            compressor: DemoCompressor(duration: .milliseconds(20)),
            library: DemoLibrary(),
            preferences: Preferences(defaults: UserDefaults(suiteName: suite) ?? .standard),
            probe: DemoVideos.probe
        )
        model.pick(DemoVideos.names(count: 1, scenario: "mixed").map { DemoVideos.pending($0) })
        for _ in 0..<200 where model.isLoading {
            try await Task.sleep(for: .milliseconds(10))
        }
        model.compress()
        for _ in 0..<500 where model.stage == .compressing {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(model.jobs.map(\.state.isFinished) == [true, true, true])
        #expect(model.summary.compressed == 1)
        #expect(model.summary.notSmaller == 1)
        #expect(model.summary.failed == 1)
    }

    @Test func anUnknownDemoFileIsUnreadable() async {
        await #expect(throws: CompressionError.unreadable) {
            try await DemoVideos.probe(URL(filePath: "/tmp/nothing.mov"))
        }
    }

    @Test func theDemoLibraryGrantsWhenAskedAndRefusesWhenDenied() async throws {
        let asked = DemoLibrary(access: .notDetermined)
        #expect(await asked.requestAccess() == .full)
        let denied = DemoLibrary(access: .denied)
        #expect(await denied.requestAccess() == .denied)
        await #expect(throws: LibraryError.denied) {
            try await denied.save(URL(filePath: "/tmp/x.mov"), original: nil, toAlbum: true)
        }
        let count = try await asked.delete(["a", "b"])
        #expect(count == 2)
        #expect(asked.deleted == ["a", "b"])
    }
}
