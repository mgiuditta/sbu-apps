#if os(iOS)
import AudioToolbox
#endif
import Foundation

/// The optional sound of the full stop settling: `punto.caf`, 40 ms, off unless the person turns it
/// on in Impostazioni (`isEnabledKey`).
nonisolated enum SbuSound {
    /// The `UserDefaults` key of the setting.
    static let isEnabledKey = "sbu.sound"

    /// The bundled sound, if this build ships it.
    static var url: URL? {
        Bundle.module.url(forResource: "punto", withExtension: "caf")
    }

    #if os(iOS)
    private static let soundID: SystemSoundID? = {
        guard let url else { return nil }
        var id: SystemSoundID = 0
        return AudioServicesCreateSystemSoundID(url as CFURL, &id) == kAudioServicesNoError ? id : nil
    }()

    /// Plays the sound if the person turned it on.
    static func playIfEnabled() {
        guard UserDefaults.standard.bool(forKey: isEnabledKey), let soundID else { return }
        AudioServicesPlaySystemSound(soundID)
    }
    #else
    /// Apple Watch has no system sounds: the `dot` haptic is the only sign.
    static func playIfEnabled() {}
    #endif
}
