import Foundation
import ImageIO
import Testing
@testable import SbuClean

/// The pictures made by `Fixtures/make_fixtures.py --tests`, with the Vision prints that
/// `Fixtures/vision_prints.swift` computed for them on the Mac: the thresholds and the best shot
/// must hold on real feature prints, not only on hand-made ones. The simulator cannot run
/// Vision, so the live check runs on a device only.
struct FixtureGroupingTests {
    private final class BundleToken {}

    private static let names = [
        "distinct-0", "distinct-1", "distinct-2", "distinct-3",
        "dup-a", "dup-b", "near-a", "near-b",
        "burst-0", "burst-1", "burst-2-blurry",
    ]

    private static var bundle: Bundle {
        Bundle(for: BundleToken.self)
    }

    private nonisolated static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private static func image(_ name: String) throws -> CGImage {
        let url = try #require(bundle.url(forResource: name, withExtension: "jpg"), "missing fixture \(name)")
        let source = try #require(CGImageSourceCreateWithURL(url as CFURL, nil))
        return try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
    }

    /// The fixtures as one session a second apart, analysed with the Mac's Vision prints.
    private static func library() throws -> (items: [MediaItem], analyses: [String: ImageAnalysis]) {
        let url = try #require(bundle.url(forResource: "vision-prints", withExtension: "json"))
        let prints = try JSONDecoder().decode([String: [Float]].self, from: Data(contentsOf: url))
        let start = Fixture.date(1, 1)
        var items: [MediaItem] = []
        var analyses: [String: ImageAnalysis] = [:]
        for (index, name) in names.enumerated() {
            let image = try image(name)
            let print = try #require(prints[name], "no print for \(name)")
            analyses[name] = ImageAnalysis(featurePrint: print, sharpness: ImageAnalyzer.sharpness(of: image))
            items.append(MediaItem(id: name, creationDate: start.addingTimeInterval(Double(index)), kind: .photo,
                                   pixelWidth: image.width, pixelHeight: image.height))
        }
        return (items, analyses)
    }

    @Test func featurePrintsAreRevisionTwo() throws {
        let library = try Self.library()
        #expect(library.analyses.values.allSatisfy { $0.featurePrint.count == 768 })
    }

    @Test func groupsTheFixtureSetAsExpected() throws {
        let library = try Self.library()

        let groups = SimilarityGrouper().groups(of: library.items, analyses: library.analyses)
        let byMembers = Dictionary(uniqueKeysWithValues: groups.map { (Set($0.members), $0.kind) })

        #expect(byMembers[["dup-a", "dup-b"]] == .duplicate)
        #expect(byMembers[["near-a", "near-b"]] == .similar)
        #expect(byMembers[["burst-0", "burst-1", "burst-2-blurry"]] == .similar)
        #expect(groups.count == 3, "distinct pictures must stay alone: \(groups.map(\.members))")
    }

    @Test func copiesTakenOnDifferentDaysAreStillDuplicates() throws {
        var library = try Self.library()
        // Saved again a year later: the same file, so the same size.
        for id in ["dup-a", "dup-b"] {
            if let index = library.items.firstIndex(where: { $0.id == id }) {
                library.items[index].size = ItemSize(bytes: 123_456)
            }
        }
        if let index = library.items.firstIndex(where: { $0.id == "dup-b" }) {
            library.items[index].creationDate = Fixture.date(6, 1, year: 2027)
        }

        let groups = SimilarityGrouper().groups(of: library.items, analyses: library.analyses)

        #expect(groups.contains { Set($0.members) == ["dup-a", "dup-b"] && $0.kind == .duplicate })
        #expect(!groups.contains { $0.members.contains("near-a") && $0.members.contains("dup-a") })
    }

    @Test func theBlurredShotIsNeverTheBest() throws {
        let library = try Self.library()

        let burst = try #require(SimilarityGrouper().groups(of: library.items, analyses: library.analyses).first { $0.members.contains("burst-0") })

        #expect(burst.best != "burst-2-blurry")
        #expect(burst.members.last == "burst-2-blurry" || burst.members.dropFirst().contains("burst-2-blurry"))
        let blurry = try #require(library.analyses["burst-2-blurry"])
        let sharp = try #require(library.analyses["burst-0"])
        #expect(sharp.sharpness > blurry.sharpness * BestShot.sharpnessRatio)
    }

    @Test(.enabled(if: !isSimulator, "Vision needs a device"))
    func liveVisionMatchesTheStoredPrints() throws {
        let stored = try Self.library().analyses
        for name in ["dup-a", "burst-0"] {
            let live = try #require(ImageAnalyzer.visionAnalysis(of: Self.image(name)))
            let print = try #require(stored[name]?.featurePrint)
            #expect(FeatureDistance.between(live.featurePrint, print) < 0.05)
        }
    }

    @Test func theSimulatorStandInSeparatesCopiesFromOtherPictures() throws {
        let copy = TinyImageDescriptor.describe(try Self.image("dup-a"))
        let resaved = TinyImageDescriptor.describe(try Self.image("dup-b"))
        let other = TinyImageDescriptor.describe(try Self.image("distinct-0"))

        #expect(copy.count == TinyImageDescriptor.width * TinyImageDescriptor.height)
        #expect(FeatureDistance.between(copy, resaved) < SimilarityGrouper().duplicateDistance)
        #expect(FeatureDistance.between(copy, other) > SimilarityGrouper().similarDistance)
    }
}
