import DeviceActivity
import Foundation
import ManagedSettings

/// Runs when a Screen Time schedule starts or ends. Modalità post: its schedule starts when the
/// 10 minutes are up, and the Shield covers the apps again.
final class MonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity == PostMode.activity else { return }
        let defaults = UserDefaults(suiteName: "group.dev.sbu.social") ?? .standard
        ShieldSettings.load(from: defaults).apply(to: ManagedSettingsStore(named: ShieldSettings.storeName))
        PostMode.setEnd(nil, in: defaults)
        DeviceActivityCenter().stopMonitoring([activity])
    }
}
