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

struct SoundEngineStereoTests {
    @Test func aSoundInTheCenterIsHeardInBothEars() async throws {
        let engine = SoundEngine()
        try engine.addNoise(.pink, id: "a")
        let levels = await engine.outputLevels(over: .milliseconds(500))
        engine.removeAll()
        try #require(levels.count == 2)
        #expect(levels[0] > 0)
        #expect(abs(levels[0] - levels[1]) / max(levels[0], levels[1]) < 0.2, "left \(levels[0]) right \(levels[1])")
    }

    @Test func panMovesTheSoundToOneSide() async throws {
        let engine = SoundEngine()
        try engine.addNoise(.pink, id: "a")
        engine.setPan(-1, for: "a")
        let levels = await engine.outputLevels(over: .milliseconds(500))
        engine.removeAll()
        try #require(levels.count == 2)
        #expect(levels[0] > 4 * levels[1], "left \(levels[0]) right \(levels[1])")
    }
}
