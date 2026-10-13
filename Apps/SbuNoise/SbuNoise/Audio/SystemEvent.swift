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
    /// The hardware changed (a new output, a sample rate change): the engine may have stopped.
    case configurationChanged

    /// Reads an `AVAudioSession.interruptionNotification`.
    init?(interruption info: [AnyHashable: Any]) {
        guard let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return nil }
        switch type {
        case .began:
            self = .interruptionBegan
        case .ended:
            let options = AVAudioSession.InterruptionOptions(rawValue: info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0)
            self = .interruptionEnded(shouldResume: options.contains(.shouldResume))
        @unknown default:
            return nil
        }
    }

    /// Reads an `AVAudioSession.routeChangeNotification`: a lost output pauses, a new one (headphones
    /// plugged in) changes how the mix is rendered.
    init?(routeChange info: [AnyHashable: Any]) {
        guard let raw = info[AVAudioSessionRouteChangeReasonKey] as? UInt else { return nil }
        switch AVAudioSession.RouteChangeReason(rawValue: raw) {
        case .oldDeviceUnavailable: self = .outputLost
        case .newDeviceAvailable: self = .configurationChanged
        default: return nil
        }
    }
}
