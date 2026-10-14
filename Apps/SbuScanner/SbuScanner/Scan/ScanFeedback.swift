import AudioToolbox
import UIKit

/// The sound and buzz when a code is read, each one a setting.
enum ScanFeedback {
    static func play(sound: Bool, vibration: Bool) {
        // 1057 is the short "Tink" of the keyboard, quiet and system-wide; it follows the silent switch.
        if sound { AudioServicesPlaySystemSound(1057) }
        if vibration { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    }
}
