import Foundation
import Observation

/// The permission iOS gives, and the reminder notifications kept with iOS.
///
/// The plan is made again after every save, at launch and each time the app comes back, so it
/// always matches the reminders and the odometer you logged.
@Observable
final class ReminderNotifications {
    private static let sentKey = "notifications.sentKeys"

    private(set) var access: NotificationAccess = .notDetermined

    @ObservationIgnored private let center: any ReminderCenter
    @ObservationIgnored private let defaults: UserDefaults
    /// Bumped by each reschedule, so a plan that waited on iOS never overwrites a newer one.
    @ObservationIgnored private var generation = 0

    init(center: any ReminderCenter, defaults: UserDefaults = .standard) {
        self.center = center
        self.defaults = defaults
    }

    /// Plans every notification again. Never asks: permission is asked when you save a reminder.
    func reschedule(_ reminders: [ReminderInput], now: Date = .now, calendar: Calendar = .current) async {
        generation += 1
        let current = generation
        access = await center.access()
        guard current == generation else { return }
        guard access == .allowed else {
            center.replace(with: [])
            return
        }
        let plan = ReminderPlan.plan(reminders, now: now, calendar: calendar)
        var sent = Set(defaults.stringArray(forKey: Self.sentKey) ?? [])
        let fresh = plan.immediate.filter { !sent.contains($0.key) }
        sent.formUnion(fresh.map(\.key))
        // Only keys still due are kept: once the service is logged, the next due reading announces again.
        sent.formIntersection(plan.immediate.map(\.key))
        defaults.set(Array(sent), forKey: Self.sentKey)
        center.replace(with: plan.scheduled + fresh.map(\.notification))
    }

    /// Shows iOS's prompt the first time; afterwards only reads the answer.
    func requestAccess() async {
        access = await center.access()
        if access == .notDetermined {
            access = await center.requestAccess()
        }
    }

    func refreshAccess() async {
        access = await center.access()
    }
}
