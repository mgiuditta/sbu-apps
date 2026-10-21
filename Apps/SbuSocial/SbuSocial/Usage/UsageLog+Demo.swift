import Foundation

extension UsageLog {
    /// Screenshots and UI tests run on made-up minutes, in their own store, never touching yours.
    static var isDemo: Bool {
        UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || UserDefaults.standard.bool(forKey: "SBU_DEMO")
    }

    /// A week as SocialLite's screenshots show it: less every day, with a 45-minute limit.
    static func demo(now: Date = .now, calendar: Calendar = .current) -> UsageLog {
        let suite = "dev.sbu.social.demo"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        defaults.removePersistentDomain(forName: suite)
        let minutes: [(Platform, [Int])] = [
            (.instagram, [52, 47, 38, 41, 30, 26, 18]),
            (.youtube, [35, 30, 33, 22, 20, 15, 12]),
            (.reddit, [12, 10, 8, 9, 6, 5, 4]),
        ]
        for offset in 0..<7 {
            let day = calendar.date(byAdding: .day, value: offset - 6, to: now) ?? now
            let log = UsageLog(defaults: defaults, calendar: calendar, now: { day })
            for (platform, week) in minutes { log.add(week[offset] * 60, on: platform) }
            log.save()
        }
        let usage = UsageLog(defaults: defaults, calendar: calendar)
        usage.limitMinutes = 45
        return usage
    }
}
