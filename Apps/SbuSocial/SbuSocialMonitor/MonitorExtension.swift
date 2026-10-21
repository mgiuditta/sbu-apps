import DeviceActivity
import Foundation
import ManagedSettings

/// Runs when a Screen Time schedule starts or ends, and brings the Shield to what the settings say:
/// Modalità post's return, tonight's Sonno, the end of a focus session or of the limit's day.
final class MonitorExtension: DeviceActivityMonitor {
    private let defaults = UserDefaults(suiteName: "group.dev.sbu.social") ?? .standard
    private let store = ManagedSettingsStore(named: ShieldSettings.storeName)

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        var settings = ShieldSettings.load(from: defaults)
        switch activity {
        case PostMode.activity:
            settings.postModeEnd = nil
            DeviceActivityCenter().stopMonitoring([activity])
        case SleepSettings.activity:
            settings.isSleeping = settings.sleep.isOn && settings.sleep.isNight(startingAt: .now)
        default:
            break
        }
        commit(settings)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        var settings = ShieldSettings.load(from: defaults)
        switch activity {
        case SleepSettings.activity:
            settings.isSleeping = false
        case ShieldSettings.focusActivity:
            settings.focusEnd = nil
        case ShieldSettings.limitActivity:
            settings.limitDay = nil
        default:
            break
        }
        commit(settings)
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        let settings = ShieldSettings.load(from: defaults)
        guard activity == SleepSettings.activity, settings.sleep.isOn,
              settings.sleep.isNight(startingAt: .now.addingTimeInterval(30 * 60)) else { return }
        Task {
            await ShieldNotice.post(id: "sleep-warning", title: String(localized: "Tra 30 minuti è ora di dormire"),
                                    body: String(localized: "Poi i social si chiudono fino al mattino."))
        }
    }

    private func commit(_ settings: ShieldSettings) {
        settings.save(to: defaults)
        settings.apply(to: store)
    }
}
