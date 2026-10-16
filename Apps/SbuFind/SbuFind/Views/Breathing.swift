import Foundation

/// Whether the endless breathing of the ring and the scan disc runs.
///
/// Off with Reduce Motion, and with `-STILL_ANIMATIONS YES`: UI tests wait for the app to stop
/// animating before each tap, which an endless animation never does, and screenshots want a
/// still frame.
enum Breathing {
    static func isAllowed(reduceMotion: Bool, defaults: UserDefaults = .standard) -> Bool {
        !reduceMotion && !defaults.bool(forKey: "STILL_ANIMATIONS") && !defaults.bool(forKey: "FASTLANE_SNAPSHOT")
    }
}
