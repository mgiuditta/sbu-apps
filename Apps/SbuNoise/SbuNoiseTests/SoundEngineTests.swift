import Testing
@testable import SbuNoise

struct SoundEngineTests {
    @Test func layersFadeTogetherAndLeave() async throws {
        let engine = SoundEngine()
        try engine.addNoise(.pink, id: "a")
        try engine.addNoise(.brown, id: "b")
        engine.setVolume(0.5, for: "a")
        engine.setPitch(200, for: "b")
        #expect(engine.volume(for: "a") == 0.5)

        await engine.fadeOutput(to: 0, over: .milliseconds(100))
        #expect(engine.outputVolume == 0)

        engine.replaceAll()
        #expect(engine.layerIDs.isEmpty)
        engine.outputVolume = 1
    }
}
