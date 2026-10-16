import AudioToolbox

/// The sound when a code is read, a setting of its own. The haptic is a Sbu sign the screen plays:
/// the Closure when the code is saved, `dot` otherwise.
enum ScanFeedback {
    static func play(sound: Bool) {
        // 1057 is the short "Tink" of the keyboard, quiet and system-wide; it follows the silent switch.
        if sound { AudioServicesPlaySystemSound(1057) }
    }
}
