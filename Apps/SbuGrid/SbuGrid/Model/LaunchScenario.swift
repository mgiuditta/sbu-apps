import Foundation

/// How the app starts: with what the user left, or, for UI tests and screenshots, from a clean
/// state that is never saved.
///
/// `-GRID_PHOTO demo` starts on the drawn still life, `-GRID_PHOTO none` on the empty screen;
/// `-FASTLANE_SNAPSHOT YES` is the demo.
nonisolated enum LaunchScenario: Equatable, Sendable {
    case user
    case demo
    case empty

    init(defaults: UserDefaults) {
        switch defaults.string(forKey: "GRID_PHOTO") {
        case "demo": self = .demo
        case "none": self = .empty
        default: self = defaults.bool(forKey: "FASTLANE_SNAPSHOT") ? .demo : .user
        }
    }
}
