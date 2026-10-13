import AVFAudio
import Foundation
import Testing
@testable import SbuNoise

struct MixTests {
    @Test func newSoundsSpreadAroundTheListenerFromTheFront() {
        let mix = Mix(name: "Mix", soundIDs: ["a", "b", "c", "d"])
        let points = mix.layers.map(\.position)
        #expect(abs(points[0].x) < 1e-9 && abs(points[0].y + 0.5) < 1e-9) // front
        #expect(abs(points[1].x - 0.5) < 1e-9 && abs(points[1].y) < 1e-9) // right
        #expect(points.allSatisfy { abs($0.distance - 0.5) < 1e-9 })
    }

    @Test func aMixHoldsAtMostFiveSounds() {
        var mix = Mix(name: "Mix", soundIDs: ["a", "b", "c", "d", "e", "f"])
        #expect(mix.layers.count == 5)
        #expect(mix.isFull)
        mix.add("g")
        #expect(mix.layers.count == 5)
    }

    @Test func resetKeepsOnlyTheSoundAndItsPlace() {
        var layer = MixLayer(soundID: "a", position: MixPoint(x: 0.3, y: 0.2))
        layer.volume = 0.2
        layer.pitch = 300
        layer.variance = 0.5
        layer.speed = 1
        #expect(layer.reset() == MixLayer(id: layer.id, soundID: "a", position: MixPoint(x: 0.3, y: 0.2)))
    }

    @Test func aPointOutsideThePadIsPulledToItsEdge() {
        let point = MixPoint(x: 3, y: 4).insidePad
        #expect(abs(point.x - 0.6) < 1e-9 && abs(point.y - 0.8) < 1e-9)
        #expect(MixPoint(x: 0.2, y: 0.1).insidePad == MixPoint(x: 0.2, y: 0.1))
    }
}

struct MixSpaceTests {
    /// Left stays left, and the top of the pad (negative y) is in front of the listener (negative z).
    @Test(arguments: [
        (MixPoint(x: -1, y: 0), AVAudio3DPoint(x: -1, y: 0, z: 0)),
        (MixPoint(x: 0.5, y: -0.5), AVAudio3DPoint(x: 0.5, y: 0, z: -0.5)),
        (MixPoint(x: 0, y: 1), AVAudio3DPoint(x: 0, y: 0, z: 1)),
        (.center, AVAudio3DPoint(x: 0, y: 0, z: 0)),
    ])
    func aPlaceOnThePadIsADirectionAroundTheListener(point: MixPoint, expected: AVAudio3DPoint) {
        let position = MixSpace.position3D(at: point)
        #expect(position.x == expected.x && position.y == expected.y && position.z == expected.z)
    }

    @Test(arguments: [(-2, -1), (-0.5, -0.5), (0, 0), (0.7, 0.7), (5, 1)] as [(Double, Float)])
    func panFollowsLeftAndRight(x: Double, pan: Float) {
        #expect(MixSpace.pan(at: MixPoint(x: x, y: 0.3)) == pan)
    }

    @Test(arguments: [
        ([AVAudioSession.Port.headphones], true),
        ([.bluetoothA2DP], true),
        ([.bluetoothLE], true),
        ([.builtInSpeaker], false),
        ([.builtInReceiver], false),
        ([.HDMI, .airPlay], false),
        ([], false),
    ])
    func onlyHeadphonesHearFrontAndBack(outputs: [AVAudioSession.Port], hears: Bool) {
        #expect(MixSpace.hearsFrontAndBack(on: outputs) == hears)
    }

    @Test(arguments: [(0, 1), (0.5, 2.0 / 3), (1, 1.0 / 3), (2, 1.0 / 3)] as [(Double, Float)])
    func nearerIsLouder(distance: Double, gain: Float) {
        #expect(abs(MixSpace.gain(at: MixPoint(x: 0, y: distance)) - gain) < 1e-6)
    }

    @Test func aSoundWithoutVarianceStaysPut() {
        let layer = MixLayer(soundID: "a", position: MixPoint(x: 0.4, y: -0.2))
        #expect(MixSpace.position(of: layer, at: 123) == layer.position)
    }

    @Test(arguments: [0.0, 1.7, 12.5, 600])
    func aWanderingSoundStaysWithinItsVariance(time: TimeInterval) {
        let layer = MixLayer(soundID: "a", position: MixPoint(x: 0.4, y: -0.2), variance: 0.3, speed: 0.8)
        let point = MixSpace.position(of: layer, at: time)
        #expect(abs(point.x - 0.4) <= 0.3 + 1e-9)
        #expect(abs(point.y + 0.2) <= 0.3 + 1e-9)
    }

    @Test func fasterMeansFurtherInTheSameTime() {
        let slow = MixLayer(soundID: "a", position: .center, variance: 0.5, speed: 0)
        let fast = MixLayer(soundID: "a", position: .center, variance: 0.5, speed: 1)
        #expect(abs(MixSpace.position(of: fast, at: 1).x) > abs(MixSpace.position(of: slow, at: 1).x))
    }
}

struct LibraryTests {
    private let store = NoiseStore.temporary

    @Test func mixesAreSavedReplacedAndDeleted() {
        let library = Library(store: store)
        var mix = Mix(name: "Mare", soundIDs: ["noise.pink"])
        library.save(mix)
        mix.name = "Mare di notte"
        library.save(mix)
        #expect(Library(store: store).mixes == [mix])
        library.delete(mix.id)
        #expect(Library(store: store).mixes.isEmpty)
    }

    @Test func mixesAndTimersKeepEachOther() throws {
        try store.save(NoiseFile(timers: [SoundTimer()]))
        Library(store: store).save(Mix(name: "Mare", soundIDs: ["noise.pink"]))
        let file = try store.load()
        #expect(file.timers.count == 1)
        #expect(file.mixes.count == 1)
    }

    @Test func newMixesGetTheFirstFreeNumber() {
        let library = Library(store: store)
        #expect(library.newMixName() == String(localized: "Mix 1"))
        library.save(Mix(name: String(localized: "Mix 1"), soundIDs: ["noise.pink"]))
        #expect(library.newMixName() == String(localized: "Mix 2"))
    }
}
