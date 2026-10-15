import AudioToolbox

/// The short system sound of a captured measure: a lock, or a calibration step. It follows the
/// ringer switch and volume like any system sound.
nonisolated enum MeasureSound {
    /// The system "Tink".
    private static let soundID: SystemSoundID = 1057

    static func play() {
        AudioServicesPlaySystemSound(soundID)
    }
}
