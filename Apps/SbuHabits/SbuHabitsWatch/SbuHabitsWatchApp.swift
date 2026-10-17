import SbuKit
import SwiftUI
import WatchConnectivity

@main
struct SbuHabitsWatchApp: App {
    // Created once here, with the session: a grid can arrive before any view.
    @State private var habits: WatchHabits

    init() {
        let habits = WatchHabits.isDemo ? WatchHabits.demo(store: .shared) : WatchHabits()
        let bridge = WatchSessionBridge()
        // Lives as long as the app: one session for the whole process.
        Task {
            for await event in bridge.events {
                habits.handle(event)
            }
        }
        if WatchHabits.isDemo == false {
            bridge.activate()
        }
        _habits = State(initialValue: habits)
    }

    var body: some Scene {
        WindowGroup {
            TodayView(habits: habits)
                .tint(SbuTheme.ink)
                // No shell on the watch: the accent of the full stop comes from here.
                .environment(\.sbuAccent, .habits)
        }
        // watchOS wakes the app in the background to deliver a grid: stay until it is in.
        .backgroundTask(.watchConnectivity) {
            await Self.waitForPendingContent()
        }
    }

    /// Waits while WatchConnectivity still has something to deliver, up to a few seconds.
    private static func waitForPendingContent() async {
        var waits = 0
        while WCSession.default.hasContentPending, waits < 20, Task.isCancelled == false {
            try? await Task.sleep(for: .milliseconds(250))
            waits += 1
        }
    }
}
