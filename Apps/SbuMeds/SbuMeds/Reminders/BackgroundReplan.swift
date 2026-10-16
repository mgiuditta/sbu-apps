import BackgroundTasks
import Foundation
import SwiftData
import WidgetKit

/// Rebuilds the reminders while the app is closed, so the 64 notifications iOS keeps roll
/// forward without opening Sbu Meds. Opportunistic: iOS decides when, and never after a
/// force-quit; opening the app, a notification action and a save rebuild the plan as well.
enum BackgroundReplan {
    /// Also in `BGTaskSchedulerPermittedIdentifiers`.
    nonisolated static let identifier = "dev.sbu.meds.replan"
    /// The earliest the next refresh may run; iOS picks the moment around how you use the iPhone.
    nonisolated static let interval: TimeInterval = 6 * 3_600

    /// Asks iOS for the next refresh; one request replaces the one before.
    nonisolated static func scheduleNext(now: Date = .now) {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = now.addingTimeInterval(interval)
        // Not permitted in the simulator or with Background App Refresh off: the foreground still replans.
        try? BGTaskScheduler.shared.submit(request)
    }

    /// Closes the days that ended, saves, and plans every reminder again; the widget follows.
    static func run(container: ModelContainer, reminders: Reminders, now: Date = .now, calendar: Calendar = .current) async {
        let context = container.mainContext
        Cabinet.closePastDays(in: context, now: now, calendar: calendar)
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
        let medicines = ((try? context.fetch(FetchDescriptor<Medicine>())) ?? []).map(\.snapshot)
        await reminders.reschedule(medicines, now: now, calendar: calendar)
    }
}
