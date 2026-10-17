import AudioToolbox

/// Plays the sound of one tick. The tap that goes with it is the Sbu `tick` haptic, which the
/// finder plays on each step of the same rhythm.
///
/// The sound is a system sound, so it follows the ringer switch and the volume: in silent mode
/// only the tap is felt.
nonisolated enum ProximityTicker {
    /// The system "Tink", as Sbu Level's measure sound.
    private static let soundID: SystemSoundID = 1057

    static func playSound() {
        AudioServicesPlaySystemSound(soundID)
    }
}
