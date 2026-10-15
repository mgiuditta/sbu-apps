import Foundation
import Observation

/// The "Da ricomprare" reminder: off by default; when on, one notification at the time you chose
/// naming what is at or below its minimum.
@Observable
final class LowStockReminders {
    static let isOnKey = "lowStock.reminder"
    static let minutesKey = "lowStock.minutes"
    /// 18:00, when the shops are still open.
    static let defaultMinutes = 18 * 60

    private(set) var isOn: Bool
    private(set) var minutesAfterMidnight: Int
    /// Turned on, but iOS doesn't let Sbu Inventory notify.
    private(set) var isDenied = false

    private let center: any ReminderCenter
    private let defaults: UserDefaults

    init(center: any ReminderCenter, defaults: UserDefaults = .standard) {
        self.center = center
        self.defaults = defaults
        isOn = defaults.bool(forKey: Self.isOnKey)
        minutesAfterMidnight = defaults.object(forKey: Self.minutesKey) as? Int ?? Self.defaultMinutes
    }

    /// Turns the reminder on, asking iOS first; stays off when you don't allow notifications.
    func setOn(_ on: Bool) async {
        if on {
            let allowed = await center.requestAuthorization()
            isDenied = !allowed
            isOn = allowed
        } else {
            isOn = false
            isDenied = false
        }
        defaults.set(isOn, forKey: Self.isOnKey)
    }

    func setTime(_ minutes: Int) {
        minutesAfterMidnight = min(max(minutes, 0), 24 * 60 - 1)
        defaults.set(minutesAfterMidnight, forKey: Self.minutesKey)
    }

    /// Checks again whether iOS lets the reminder through, after you came back from Settings.
    func refreshAccess() async {
        guard isOn else { return }
        isDenied = !(await center.isAuthorized())
    }

    /// Plans the notification again for the items that are low right now.
    func reschedule(lowItems: [String], now: Date = .now) async {
        let reminder = isOn
            ? LowStockReminderPlan.plan(lowItems: lowItems, minutesAfterMidnight: minutesAfterMidnight, now: now, calendar: .current, locale: .current)
            : nil
        await center.replace(with: reminder)
    }
}
