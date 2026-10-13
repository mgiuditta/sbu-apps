import Testing
@testable import SbuNoise

struct SoundEngineTests {
    @Test func noiseLayerFadesAndLeaves() async throws {
        let engine = SoundEngine()
        try engine.addNoise(.pink, id: "noise.pink")
        engine.setVolume(1, for: "noise.pink")

        await engine.fade("noise.pink", to: 0, over: .milliseconds(100))
        #expect(engine.volume(for: "noise.pink") == 0)

        engine.remove("noise.pink")
        #expect(engine.layerIDs.isEmpty)
    }
}
