import Foundation
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

    /// A generated noise and a loop, both mastered at -18 LUFS, reach the output at the same
    /// level relative to what they carry: the generator's gains make up for what its mono source
    /// loses in the layer's mixer.
    @Test func aNoiseAndALoopReachTheOutputAlike() async throws {
        let noise = SoundEngine()
        try noise.addNoise(.white, id: "a")
        noise.setSpatial(false)
        noise.setPosition(.center, for: "a")
        let noiseOut = await noise.outputRMS(over: .milliseconds(800))
        noise.removeAll()
        // White noise from NoiseGenerator: uniform in ±0.1246, so RMS 0.1246 / √3.
        let noiseFirst = try #require(noiseOut.first)
        let noiseRatio = noiseFirst / (Float(0.1246) / Float(3).squareRoot())

        let loop = SoundEngine()
        let url = try #require(Bundle.main.url(forResource: "rain.heavy", withExtension: "caf"))
        let buffer = try SoundEngine.loadLoop(url, padding: SoundEngine.loopPadding)
        let data = try #require(buffer.floatChannelData)
        var energy: Double = 0
        for frame in 0..<Int(buffer.frameLength) { energy += Double(data[0][frame] * data[0][frame]) }
        try loop.addLoop(buffer, id: "a")
        loop.setSpatial(false)
        loop.setPosition(.center, for: "a")
        let loopOut = await loop.outputRMS(over: .milliseconds(800))
        loop.removeAll()
        let loopFirst = try #require(loopOut.first)
        let loopRatio = loopFirst / Float((energy / Double(buffer.frameLength)).squareRoot())

        // Within 1 dB once the generator's 1.2 dB make-up is counted.
        let difference = 20 * log10(Double(noiseRatio * 1.152 / loopRatio))
        #expect(abs(difference) < 1, "noise \(noiseRatio) loop \(loopRatio)")
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
