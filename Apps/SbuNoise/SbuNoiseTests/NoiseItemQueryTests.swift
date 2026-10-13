import Testing
@testable import SbuNoise

struct NoiseItemQueryTests {
    @Test func offersTheSoundsThenTheMixes() {
        let mix = Mix(name: "Temporale", soundIDs: ["noise.pink"])
        let entities = NoiseItemQuery.entities(mixes: [mix])
        #expect(entities.map(\.id) == Sound.generated.map(\.id) + [mix.id.uuidString])
        #expect(entities.last?.name == "Temporale")
        #expect(entities.last?.systemImage == "square.stack.3d.up")
    }

    @Test func anEntityPlaysItsItem() {
        let entity = NoiseItemEntity(.sound(Sound.generated[0]))
        #expect(PlaySoundIntent(sound: entity).sound?.id == "noise.white")
    }
}
