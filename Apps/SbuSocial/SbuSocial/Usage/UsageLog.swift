import Foundation
import Observation

/// The seconds spent on each Platform inside Sbu Social, day by day, and the Limite di tempo.
/// Kept in the app group, so the widget and the Screen Time extensions can read them.
@Observable
final class UsageLog {
    /// The Limite di tempo choices, in minutes; 0 is no limit.
    static let limits = [0, 15, 30, 45, 60, 90, 120]

    private var seconds: [String: [Platform: Int]]
    /// Minutes a day across every Platform; 0 means no limit.
    var limitMinutes: Int {
        didSet { defaults.set(limitMinutes, forKey: "limitMinutes") }
    }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var lastSave = Date.distantPast

    init(defaults: UserDefaults = .appGroup, calendar: Calendar = .current, now: @escaping () -> Date = Date.init) {
        self.defaults = defaults
        self.calendar = calendar
        self.now = now
        seconds = defaults.data(forKey: "usage").flatMap { try? JSONDecoder().decode([String: [Platform: Int]].self, from: $0) } ?? [:]
        limitMinutes = defaults.integer(forKey: "limitMinutes")
    }

    /// Adds time spent on a Platform today. Saved at most every 15 seconds, and by `save()`.
    func add(_ seconds: Int, on platform: Platform) {
        self.seconds[key(for: now()), default: [:]][platform, default: 0] += seconds
        if now().timeIntervalSince(lastSave) >= 15 { save() }
    }

    func minutes(on day: Date, platform: Platform? = nil) -> Int {
        let day = seconds[key(for: day)] ?? [:]
        let total = platform.map { day[$0] ?? 0 } ?? day.values.reduce(0, +)
        return total / 60
    }

    var minutesToday: Int {
        minutes(on: now())
    }

    /// The Limite di tempo is set and today's minutes have reached it.
    var isOverLimit: Bool {
        limitMinutes > 0 && minutesToday >= limitMinutes
    }

    /// The last seven days, oldest first, today last.
    var lastSevenDays: [Date] {
        let today = calendar.startOfDay(for: now())
        return (0..<7).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }

    /// Minutes a day over the last seven days, today included.
    var averageMinutes: Int {
        lastSevenDays.map { minutes(on: $0) }.reduce(0, +) / 7
    }

    func save() {
        lastSave = now()
        defaults.set(try? JSONEncoder().encode(seconds), forKey: "usage")
    }

    private func key(for date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }
}
