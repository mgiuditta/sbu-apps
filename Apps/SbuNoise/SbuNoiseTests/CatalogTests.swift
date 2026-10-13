import AVFAudio
import Foundation
import Testing
@testable import SbuNoise

struct CatalogTests {
    @Test func idsAreUnique() {
        let ids = Sound.catalog.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func everyGroupHasSounds() {
        for group in SoundCategory.allCases {
            #expect(Sound.catalog.contains { $0.category == group }, "\(group) is empty")
        }
    }

    @Test func idsStartWithTheirGroup() {
        let prefixes: [SoundCategory: String] = [.noise: "noise.", .rain: "rain.", .water: "water.", .nature: "nature.", .home: "home.", .travel: "travel."]
        for sound in Sound.catalog {
            #expect(sound.id.hasPrefix(prefixes[sound.category] ?? "?"), "\(sound.id)")
        }
    }

    /// Every loop is in the bundle, stereo, and long enough not to be heard repeating.
    @Test(arguments: Sound.catalog.filter(\.source.isLoop))
    func loopIsBundledAndReadable(sound: Sound) throws {
        let url = try #require(sound.source.url, "Sounds/\(sound.id).caf is missing")
        let buffer = try SoundEngine.loadLoop(url, padding: SoundEngine.loopPadding)
        #expect(buffer.format.channelCount == 2)
        #expect(Double(buffer.frameLength) / buffer.format.sampleRate >= 55)
    }

    @Test func recordingsAreCreditedAsCC0() {
        for sound in Sound.catalog {
            guard let credit = sound.source.credit else { continue }
            #expect(credit.page.hasPrefix("https://freesound.org/people/\(credit.author)/sounds/"), "\(sound.id)")
            #expect(credit.license == "CC0 1.0")
        }
    }
}

struct SoundArrangementTests {
    private let sounds = Sound.generated
    private var ids: [String] { sounds.map(\.id) }

    @Test func noArrangementKeepsTheCatalogOrder() {
        #expect(SoundArrangement().visible(sounds).map(\.id) == ids)
    }

    @Test func newSoundsFollowTheUsersOrder() {
        let arrangement = SoundArrangement(order: ["noise.brown", "gone", "noise.white"])
        #expect(arrangement.arranged(sounds).map(\.id) == ["noise.brown", "noise.white", "noise.pink", "noise.blue", "noise.violet"])
    }

    @Test func hiddenSoundsLeaveTheVisibleList() {
        var arrangement = SoundArrangement()
        arrangement.hide("noise.pink")
        #expect(!arrangement.visible(sounds).map(\.id).contains("noise.pink"))
        #expect(arrangement.arranged(sounds).count == sounds.count)
        arrangement.show("noise.pink")
        #expect(arrangement.visible(sounds).map(\.id) == ids)
    }

    @Test(arguments: [
        (IndexSet(integer: 0), 3, ["noise.pink", "noise.brown", "noise.white", "noise.blue", "noise.violet"]),
        (IndexSet(integer: 4), 0, ["noise.violet", "noise.white", "noise.pink", "noise.brown", "noise.blue"]),
        (IndexSet([0, 1]), 5, ["noise.brown", "noise.blue", "noise.violet", "noise.white", "noise.pink"]),
    ])
    func movesLikeAList(source: IndexSet, destination: Int, expected: [String]) {
        var arrangement = SoundArrangement()
        arrangement.move(fromOffsets: source, toOffset: destination, in: sounds)
        #expect(arrangement.visible(sounds).map(\.id) == expected)
    }

    @Test func movingSkipsHiddenSounds() {
        var arrangement = SoundArrangement()
        arrangement.hide("noise.white")
        // Visible: pink, brown, blue, violet. Violet to the top.
        arrangement.move(fromOffsets: IndexSet(integer: 3), toOffset: 0, in: sounds)
        #expect(arrangement.visible(sounds).map(\.id) == ["noise.violet", "noise.pink", "noise.brown", "noise.blue"])
        #expect(arrangement.hidden == ["noise.white"])
    }

    @Test func theArrangementIsSavedInTheNoiseFile() throws {
        let store = NoiseStore.temporary
        let library = Library(store: store)
        library.arrangement.hide("noise.blue")
        library.arrangement.move(fromOffsets: IndexSet(integer: 1), toOffset: 0, in: sounds)

        let file = try store.load()
        #expect(file.hiddenSounds == ["noise.blue"])
        #expect(Library(store: store).arrangement == library.arrangement)
    }
}
