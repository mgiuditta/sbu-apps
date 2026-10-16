import Foundation
import Observation

/// Fai suonare: plays a growing beep in the Bluetooth headphones still connected to the iPhone,
/// as Wunderfind's Play Sound does. It never plays on the iPhone's own speaker: if the
/// headphones drop out while ringing, it stops.
@Observable
final class HeadphoneRinger {
    /// The connected Bluetooth headphones, or `nil`: then there is nothing to ring.
    private(set) var headphones: AudioOutput?
    private(set) var isRinging = false
    /// The last attempt to play failed: the audio session refused.
    private(set) var didFail = false

    @ObservationIgnored private let route: any AudioRouteSource
    @ObservationIgnored private let player: any TonePlayer
    @ObservationIgnored private var tone: [Float]?

    init(route: any AudioRouteSource, player: any TonePlayer) {
        self.route = route
        self.player = player
        headphones = AudioOutput.headphones(in: route.outputs)
    }

    /// The real audio session, or fixed headphones with the fixed scanner.
    static func requested(in defaults: UserDefaults) -> HeadphoneRinger {
        if FixedScanner.requested(in: defaults) != nil {
            let audio = FixedAudio()
            return HeadphoneRinger(route: audio, player: audio)
        }
        return HeadphoneRinger(route: SessionAudioRouteSource(), player: EngineTonePlayer())
    }

    /// Follows the route until the calling task is cancelled.
    func followRoute() async {
        routeChanged()
        for await _ in route.routeChanges() {
            routeChanged()
        }
    }

    func routeChanged() {
        headphones = AudioOutput.headphones(in: route.outputs)
        if headphones == nil, isRinging {
            stop()
        }
    }

    func ring() {
        guard headphones != nil, !isRinging else { return }
        let samples = tone ?? RingTone.samples()
        tone = samples
        do {
            try player.play(samples, sampleRate: RingTone.sampleRate) { [weak self] in
                self?.isRinging = false
            }
            isRinging = true
            didFail = false
        } catch {
            didFail = true
        }
    }

    func stop() {
        player.stop()
        isRinging = false
    }
}
