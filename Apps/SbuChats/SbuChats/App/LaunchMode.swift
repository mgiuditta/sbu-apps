import Foundation

/// How the app was launched: by the user, or by a test that needs made-up data.
enum LaunchMode {
    /// fastlane snapshot and the flow tests: an in-memory store, never the user's chats.
    static var isDemo: Bool { UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") }

    /// Screenshots and the chat flow tests: the sample chat already imported, with you chosen.
    static var seedsSample: Bool { isDemo && UserDefaults.standard.bool(forKey: "SEED_SAMPLE") }
}
