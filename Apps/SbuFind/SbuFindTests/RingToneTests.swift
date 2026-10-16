import Foundation
import Testing
@testable import SbuFind

struct RingToneTests {
    @Test(arguments: [(-1.0, 0.1), (0.0, 0.1), (5.0, 0.55), (10.0, 1.0), (14.0, 1.0)])
    func volumeGrowsFromSoftToFull(time: Double, volume: Double) {
        #expect(abs(RingTone.volume(at: time) - volume) < 0.0001)
    }

    @Test func volumeNeverDrops() {
        var previous = 0.0
        for step in 0...150 {
            let volume = RingTone.volume(at: Double(step) / 10)
            #expect(volume >= previous)
            #expect((RingTone.softest...1).contains(volume))
            previous = volume
        }
    }

    @Test(arguments: [(0.0, true), (0.149, true), (0.15, false), (0.39, false), (0.4, true), (-0.1, false)])
    func beepsAndPausesAlternate(time: Double, isBeeping: Bool) {
        #expect(RingTone.isBeeping(at: time) == isBeeping)
    }

    @Test func samplesLastTheWholeToneAndStayInRange() throws {
        let samples = RingTone.samples()
        #expect(samples.count == Int(RingTone.duration * RingTone.sampleRate))
        let peak = try #require(samples.map(abs).max())
        #expect(peak <= 1)
        #expect(peak > 0.9)
    }

    @Test func theStartIsSofterThanTheEnd() throws {
        let samples = RingTone.samples()
        let oneBeep = Int(RingTone.beepLength * RingTone.sampleRate)
        let firstPeak = try #require(samples.prefix(oneBeep).map(abs).max())
        let lastBeepStart = Int(14.0 * RingTone.sampleRate)
        let lastPeak = try #require(samples[lastBeepStart..<(lastBeepStart + oneBeep)].map(abs).max())
        #expect(firstPeak <= Float(RingTone.volume(at: RingTone.beepLength)) + 0.001)
        #expect(firstPeak < 0.12)
        #expect(lastPeak > 0.9)
    }

    @Test func pausesAreSilent() {
        let samples = RingTone.samples()
        let inPause = Int(0.3 * RingTone.sampleRate)
        #expect(samples[inPause] == 0)
    }
}
