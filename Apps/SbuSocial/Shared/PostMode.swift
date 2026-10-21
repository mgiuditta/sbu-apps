import DeviceActivity
import Foundation

/// Modalità post: the Shield lifts for 10 minutes so you can publish from the native app, then
/// comes back by itself.
///
/// Screen Time schedules last at least 15 minutes, so the Shield's return is the *start* of a
/// one-off schedule 10 minutes from now: the monitor extension covers the apps again when it begins.
nonisolated enum PostMode {
    static let duration: TimeInterval = 10 * 60
    static var activity: DeviceActivityName { .init("post") }

    /// The one-off schedule whose start brings the Shield back.
    static func schedule(from now: Date, calendar: Calendar = .current) -> DeviceActivitySchedule {
        let start = now.addingTimeInterval(duration)
        let end = start.addingTimeInterval(15 * 60)
        let parts: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        return DeviceActivitySchedule(intervalStart: calendar.dateComponents(parts, from: start),
                                      intervalEnd: calendar.dateComponents(parts, from: end),
                                      repeats: false)
    }

    /// When the running Modalità post ends, kept in the app group; `nil` when none is running.
    static func end(in defaults: UserDefaults) -> Date? {
        defaults.object(forKey: "postModeEnd") as? Date
    }

    static func setEnd(_ end: Date?, in defaults: UserDefaults) {
        defaults.set(end, forKey: "postModeEnd")
    }
}
