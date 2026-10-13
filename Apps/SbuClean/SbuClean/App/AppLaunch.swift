import Foundation

/// How the app starts: on the real library, or on the demo one for UI tests and screenshots.
///
/// `-FASTLANE_SNAPSHOT YES` (fastlane snapshot and the UI tests) opens the demo library with
/// fresh state; `-DemoAccess notDetermined|denied|limited` pretends another permission.
enum AppLaunch {
    static var isDemo: Bool {
        ProcessInfo.processInfo.arguments.contains("-FASTLANE_SNAPSHOT")
    }

    static func makeModel() -> CleanModel {
        guard isDemo else {
            return CleanModel(library: PhotoKitLibrary(), publish: WidgetPublisher.publish)
        }

        let directory = URL.temporaryDirectory.appending(path: "demo-\(UUID().uuidString)", directoryHint: .isDirectory)
        return CleanModel(library: DemoLibrary(access: demoAccess), directory: directory, readStorage: {
            DeviceStorage(totalBytes: 128_000_000_000, availableBytes: 21_400_000_000)
        })
    }

    private static var demoAccess: LibraryAccess {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-DemoAccess"), index + 1 < arguments.count else { return .full }

        return switch arguments[index + 1] {
        case "notDetermined": .notDetermined
        case "denied": .denied
        case "limited": .limited
        default: .full
        }
    }
}
