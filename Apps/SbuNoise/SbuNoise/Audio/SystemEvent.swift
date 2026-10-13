import AVFAudio

/// What the system asks of the player: the lock screen, Control Center, headphones and Siri send
/// commands; calls, alarms and unplugged headphones change the audio session.
nonisolated enum SystemEvent: Equatable, Sendable {
    case play
    case pause
    case togglePlayPause
    case next
    case previous
    case interruptionBegan
    case interruptionEnded(shouldResume: Bool)
    /// The output in use went away (headphones unplugged, Bluetooth out of range): pause, never
    /// carry on through the speaker.
    case outputLost
    /// The engine stopped because the hardware changed (a new output, a sample rate change).
    case configurationChanged

    /// Reads an `AVAudioSession.interruptionNotification`. A stale "began" for an app that was
    /// suspended is no event: the audio already stopped long ago.
    init?(interruption info: [AnyHashable: Any]) {
        guard let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return nil }
        switch type {
        case .began:
            let reason = (info[AVAudioSessionInterruptionReasonKey] as? UInt).flatMap(AVAudioSession.InterruptionReason.init)
            guard reason != .appWasSuspended else { return nil }
            self = .interruptionBegan
        case .ended:
            let options = AVAudioSession.InterruptionOptions(rawValue: info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0)
            self = .interruptionEnded(shouldResume: options.contains(.shouldResume))
        @unknown default:
            return nil
        }
    }

    /// Reads an `AVAudioSession.routeChangeNotification`; only a lost output matters.
    init?(routeChange info: [AnyHashable: Any]) {
        guard let raw = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              AVAudioSession.RouteChangeReason(rawValue: raw) == .oldDeviceUnavailable else { return nil }
        self = .outputLost
    }
}
