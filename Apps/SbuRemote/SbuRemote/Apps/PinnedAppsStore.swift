import Foundation
import Observation

/// Pinned apps kept on the device, next to the saved TVs.
@Observable
final class PinnedAppsStore {
    private(set) var pins: PinnedApps

    @ObservationIgnored private let defaults: UserDefaults
    nonisolated static let key = "pinnedApps"

    init(defaults: UserDefaults = UserDefaults(suiteName: AppGroup.identifier) ?? .standard) {
        self.defaults = defaults
        pins = defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(PinnedApps.self, from: $0) } ?? PinnedApps()
    }

    func toggle(_ app: TVShortcut, for tv: UUID) {
        pins.toggle(app, for: tv)
        save()
    }

    func removeAll(for tv: UUID) {
        pins.removeAll(for: tv)
        save()
    }

    /// The store of the running app; the demo TV gets an empty one of its own each launch.
    static func forApp() -> PinnedAppsStore {
        #if DEBUG
        if DemoTVClient.isEnabled, let demo = UserDefaults(suiteName: "dev.sbu.remote.demo") {
            demo.removeObject(forKey: key)
            return PinnedAppsStore(defaults: demo)
        }
        #endif
        return PinnedAppsStore()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(pins) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
