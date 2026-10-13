import AudioToolbox
import Foundation

/// Plays a bundled Sbu sound once, so the Suono choice can be heard; it follows the ring/silent
/// switch like any alert. iOS's own sound and Nessuno play nothing.
nonisolated enum ReminderSoundPlayer {
    static func play(_ sound: ReminderSound) {
        guard let name = sound.fileName, let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
        var created: SystemSoundID = 0
        guard AudioServicesCreateSystemSoundID(url as CFURL, &created) == noErr else { return }
        let soundID = created
        // Called on an audio thread: the closure must not inherit the main actor.
        AudioServicesPlaySystemSoundWithCompletion(soundID) { @Sendable in
            AudioServicesDisposeSystemSoundID(soundID)
        }
    }
}
