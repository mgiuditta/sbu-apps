import Foundation

extension WatchHabits {
    /// Whether the app shows the demo habits, for screenshots and UI checks without a paired iPhone.
    static var isDemo: Bool {
        ProcessInfo.processInfo.environment["SBU_WATCH_DEMO"] != nil || UserDefaults.standard.bool(forKey: "SBU_WATCH_DEMO")
    }

    /// The App Store demo habits and a timed one, as a grid from the iPhone.
    /// - Parameter store: A throwaway file by default; the app's own in demo mode, for the complication.
    static func demo(now: Date = .now, calendar: Calendar = .current, store: WatchStateStore = WatchStateStore(url: .temporaryDirectory.appending(path: "watch-demo.json"))) -> WatchHabits {
        let today = LogicalDay(now, calendar: calendar)
        var habits = HabitsFile.demo(today: today).habits
        var meditation = Habit(title: String(localized: "Meditare"), symbol: "brain.head.profile", createdOn: today - 30)
        _ = meditation.update(title: meditation.title, symbol: meditation.symbol, timesPerDay: 1, schedule: .everyDay, timerMinutes: 10, from: today)
        for daysAgo in 1...12 {
            meditation.log[today - daysAgo] = 1
        }
        habits.insert(meditation, at: 2)
        let tomorrow = (today + 1).noon(in: calendar)
        let snapshot = WatchSnapshot(
            habits: habits,
            today: today,
            startHour: 0,
            firstWeekday: calendar.firstWeekday,
            nextDayStart: calendar.startOfDay(for: tomorrow),
            applied: []
        )
        try? store.save(WatchState(snapshot: snapshot))
        return WatchHabits(store: store, calendar: calendar)
    }
}
