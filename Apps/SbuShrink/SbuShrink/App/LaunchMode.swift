import Foundation

/// How the app starts: on the real library and encoder, or on the demo for UI tests and
/// screenshots.
///
/// `-FASTLANE_SNAPSHOT YES` (fastlane snapshot and the UI tests) or `-Demo YES` switch to the demo
/// library, compressor and fresh preferences. Then `-DemoVideos N` starts on the settings with N
/// picked videos, `-DemoScenario mixed` adds one already light and one that fails,
/// `-DemoAccess notDetermined|denied|limited` pretends another permission, and
/// `-DemoSpeed slow` takes four seconds a video instead of a fraction.
nonisolated enum LaunchMode {
    static var isDemo: Bool {
        arguments.contains("-FASTLANE_SNAPSHOT") || arguments.contains("-Demo")
    }

    @MainActor
    static func makeModel() -> ShrinkModel {
        guard isDemo else { return ShrinkModel() }

        let suite = "dev.sbu.shrink.demo"
        UserDefaults().removePersistentDomain(forName: suite)
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        let speed: Duration = value(after: "-DemoSpeed") == "slow" ? .seconds(4) : .milliseconds(600)
        let model = ShrinkModel(
            compressor: DemoCompressor(duration: speed),
            library: DemoLibrary(access: demoAccess),
            preferences: Preferences(defaults: defaults),
            probe: DemoVideos.probe
        )
        let count = Int(value(after: "-DemoVideos") ?? "") ?? 0
        let names = DemoVideos.names(count: count, scenario: value(after: "-DemoScenario"))
        if !names.isEmpty {
            model.pick(names.map { DemoVideos.pending($0) })
        }
        return model
    }

    private static var arguments: [String] { ProcessInfo.processInfo.arguments }

    private static func value(after flag: String) -> String? {
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }

    private static var demoAccess: LibraryAccess {
        switch value(after: "-DemoAccess") {
        case "notDetermined": .notDetermined
        case "denied": .denied
        case "limited": .limited
        default: .full
        }
    }
}
