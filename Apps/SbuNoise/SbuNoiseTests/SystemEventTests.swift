import AVFAudio
import Testing
@testable import SbuNoise

struct SystemEventTests {
    private typealias Kind = AVAudioSession.InterruptionType

    @Test func interruptionBegins() {
        let info: [AnyHashable: Any] = [AVAudioSessionInterruptionTypeKey: Kind.began.rawValue]
        #expect(SystemEvent(interruption: info) == .interruptionBegan)
    }

    @Test(arguments: [true, false])
    func interruptionEndsWithTheSystemAdvice(shouldResume: Bool) {
        let options: AVAudioSession.InterruptionOptions = shouldResume ? .shouldResume : []
        let info: [AnyHashable: Any] = [
            AVAudioSessionInterruptionTypeKey: Kind.ended.rawValue,
            AVAudioSessionInterruptionOptionKey: options.rawValue,
        ]
        #expect(SystemEvent(interruption: info) == .interruptionEnded(shouldResume: shouldResume))
    }

    @Test func malformedInterruptionIsIgnored() {
        #expect(SystemEvent(interruption: [:]) == nil)
    }

    @Test(arguments: [
        (AVAudioSession.RouteChangeReason.oldDeviceUnavailable, true),
        (.newDeviceAvailable, false),
        (.categoryChange, false),
    ])
    func onlyALostOutputMatters(reason: AVAudioSession.RouteChangeReason, isEvent: Bool) {
        let info: [AnyHashable: Any] = [AVAudioSessionRouteChangeReasonKey: reason.rawValue]
        #expect((SystemEvent(routeChange: info) == .outputLost) == isEvent)
    }
}
