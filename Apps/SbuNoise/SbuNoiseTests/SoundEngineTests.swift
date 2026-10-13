import Testing
@testable import SbuNoise

/// One at a time: every engine shares the app's audio session, and one test releasing it must not
/// silence another one's measurement.
@Suite(.serialized) struct SoundEngineTests {
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

    struct Stereo {
        /// Speaker and headphones alike: a sound in the middle, in front or behind is never in one ear only.
        @Test(arguments: [false, true], [MixPoint.center, MixPoint(x: 0, y: -1), MixPoint(x: 0, y: 1)])
        func aSoundInTheMiddleIsHeardInBothEars(spatial: Bool, point: MixPoint) async throws {
            let engine = SoundEngine()
            try engine.addNoise(.pink, id: "a")
            engine.setSpatial(spatial)
            engine.setPosition(point, for: "a")
            let levels = await engine.outputLevels(over: .milliseconds(500))
            engine.removeAll()
            try #require(levels.count == 2)
            #expect(levels[0] > 0)
            #expect(abs(levels[0] - levels[1]) / max(levels[0], levels[1]) < 0.2, "left \(levels[0]) right \(levels[1])")
        }

        /// HRTF keeps some of the sound in the far ear, as a real head does.
        @Test(arguments: [(false, Float(4)), (true, 1.5)])
        func aSoundOnTheLeftIsLouderInTheLeftEar(spatial: Bool, ratio: Float) async throws {
            let engine = SoundEngine()
            try engine.addNoise(.pink, id: "a")
            engine.setSpatial(spatial)
            engine.setPosition(MixPoint(x: -1, y: 0), for: "a")
            let levels = await engine.outputLevels(over: .milliseconds(500))
            engine.removeAll()
            try #require(levels.count == 2)
            #expect(levels[0] > ratio * levels[1], "left \(levels[0]) right \(levels[1])")
        }
    }
}
