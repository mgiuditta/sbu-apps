import AudioToolbox
import UIKit

/// Plays one tick: a short system sound and a light tap.
///
/// The sound is a system sound, so it follows the ringer switch and the volume: in silent mode
/// only the tap is felt.
final class ProximityTicker {
    /// The system "Tink", as Sbu Level's measure sound.
    private static let soundID: SystemSoundID = 1057

    private let haptics = UIImpactFeedbackGenerator(style: .rigid)

    func prepare() {
        haptics.prepare()
    }

    func tick(proximity: Proximity, playsSound: Bool, vibrates: Bool) {
        if playsSound {
            AudioServicesPlaySystemSound(Self.soundID)
        }
        if vibrates {
            haptics.impactOccurred(intensity: ProximityCue.intensity(for: proximity))
            haptics.prepare()
        }
    }
}
