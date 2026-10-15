import Foundation

/// How the app was launched: by the user, or by a test that needs made-up data.
enum LaunchMode {
    /// fastlane snapshot and the flow tests: an in-memory store, never the user's chats.
    static var isDemo: Bool { UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") }

    /// Screenshots and the chat flow tests: the sample chat already imported, with you chosen.
    static var seedsSample: Bool { isDemo && UserDefaults.standard.bool(forKey: "SEED_SAMPLE") }

    /// Flow tests: a text file to import at launch, as if shared, to reach the import error screen.
    /// Lines are separated by a literal `\n`: launch arguments lose real line breaks.
    static var demoImportText: String? {
        guard isDemo, let text = UserDefaults.standard.string(forKey: "DEMO_IMPORT_TEXT") else { return nil }
        return text.replacing("\\n", with: "\n")
    }
}
