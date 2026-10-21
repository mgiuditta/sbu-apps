import DeviceActivity
import FamilyControls
import Foundation

/// Sonno, as in SocialLite: from bedtime to waking, plus a margin either side, the chosen apps are
/// shielded on the chosen days, except the apps you leave out. A notification comes 30 minutes before.
nonisolated struct SleepSettings: Codable, Equatable {
    var isOn = false
    /// Minutes after midnight.
    var bedtime = 23 * 60
    var wake = 7 * 60
    /// Minutes of Shield before bedtime and after waking.
    var margin = 30
    /// Calendar weekdays, 1 Sunday to 7 Saturday: the night belongs to the day it starts on.
    var days: Set<Int> = Set(1...7)
    /// Apps left open at night, such as messages from family.
    var excluded = FamilyActivitySelection()

    static let margins = [0, 15, 30, 60]
    static var activity: DeviceActivityName { .init("sleep") }

    /// Bedtime to waking, as on SocialLite's dial: "7h 15m".
    var duration: Duration {
        .seconds(((wake - bedtime + 24 * 60) % (24 * 60)) * 60)
    }

    /// Every night from bedtime minus the margin to waking plus the margin, warned 30 minutes before.
    var schedule: DeviceActivitySchedule {
        DeviceActivitySchedule(intervalStart: Self.clock((bedtime - margin + 24 * 60) % (24 * 60)),
                               intervalEnd: Self.clock((wake + margin) % (24 * 60)),
                               repeats: true,
                               warningTime: DateComponents(minute: 30))
    }

    /// Whether the night starting at `date` is one of the chosen days.
    func isNight(startingAt date: Date, calendar: Calendar = .current) -> Bool {
        days.contains(calendar.component(.weekday, from: date))
    }

    private static func clock(_ minutes: Int) -> DateComponents {
        DateComponents(hour: minutes / 60, minute: minutes % 60)
    }
}
