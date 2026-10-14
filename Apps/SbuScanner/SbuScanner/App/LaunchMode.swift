import Foundation

/// How the app was launched: by the user, or by a test that needs made-up data.
enum LaunchMode {
    /// fastlane snapshot and the flow tests: an in-memory store with examples and a demo camera.
    static var isDemo: Bool { UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") }
}
