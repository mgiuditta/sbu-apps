import Foundation

/// Whether the app runs on the user's libretto, or on a made-up one for screenshots and UI tests.
/// The made-up ones never read or write the user's settings.
enum LaunchMode {
    case user
    /// The sample libretto: screenshots and flow tests on data.
    case sample
    /// An empty libretto: first-run flow tests.
    case empty

    static var current: LaunchMode {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_SAMPLE_STORE") { return .sample }
        if defaults.bool(forKey: "SBU_EMPTY_STORE") { return .empty }
        return .user
    }

    var isDemo: Bool {
        self != .user
    }

    /// The course settings for this mode: the user's own, or fresh ones that vanish at the next launch.
    func courseSettings() -> CourseSettings {
        guard isDemo else { return CourseSettings() }
        let suite = "dev.sbu.libretto.demo"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.removePersistentDomain(forName: suite)
        let settings = CourseSettings(defaults: defaults)
        if self == .sample {
            settings.course = String(localized: "Ingegneria informatica")
        }
        return settings
    }
}
