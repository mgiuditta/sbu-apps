import Testing
@testable import SbuFind

struct HeadphoneRingerTests {
    let route = FixedAudio()
    let player = FakeTonePlayer()

    private func makeRinger() -> HeadphoneRinger {
        HeadphoneRinger(route: route, player: player)
    }

    @Test func seesTheConnectedHeadphones() {
        #expect(makeRinger().headphones?.name == "Buds Pro")
    }

    @Test func withoutHeadphonesNothingRings() {
        route.outputs = [AudioOutput(kind: .builtIn, name: "iPhone")]
        let ringer = makeRinger()
        ringer.ring()
        #expect(ringer.headphones == nil)
        #expect(!ringer.isRinging)
        #expect(player.plays == 0)
    }

    @Test func ringsTheWholeToneOnce() {
        let ringer = makeRinger()
        ringer.ring()
        ringer.ring()
        #expect(ringer.isRinging)
        #expect(player.plays == 1)
        #expect(player.lastSampleCount == Int(RingTone.duration * RingTone.sampleRate))
    }

    @Test func theToneEndingByItselfStopsRinging() {
        let ringer = makeRinger()
        ringer.ring()
        player.finish()
        #expect(!ringer.isRinging)
    }

    @Test func stopStopsThePlayer() {
        let ringer = makeRinger()
        ringer.ring()
        ringer.stop()
        #expect(!ringer.isRinging)
        #expect(player.stops == 1)
    }

    /// Never on the iPhone's speaker: headphones dropping out stop the tone at once.
    @Test func headphonesDroppingOutStopTheTone() {
        let ringer = makeRinger()
        ringer.ring()
        route.outputs = [AudioOutput(kind: .builtIn, name: "iPhone")]
        ringer.routeChanged()
        #expect(ringer.headphones == nil)
        #expect(!ringer.isRinging)
        #expect(player.stops == 1)
    }

    @Test func headphonesConnectingLaterCanBeRung() {
        route.outputs = []
        let ringer = makeRinger()
        route.outputs = [AudioOutput(kind: .bluetooth, name: "WH-1000XM5")]
        ringer.routeChanged()
        #expect(ringer.headphones?.name == "WH-1000XM5")
        ringer.ring()
        #expect(ringer.isRinging)
    }

    @Test func aRefusedPlaySaysSoAndDoesNotRing() {
        player.fails = true
        let ringer = makeRinger()
        ringer.ring()
        #expect(ringer.didFail)
        #expect(!ringer.isRinging)
        player.fails = false
        ringer.ring()
        #expect(!ringer.didFail)
        #expect(ringer.isRinging)
    }
}
