import SwiftData
import SwiftUI
import UserNotifications

@main
struct SbuMedsApp: App {
    // ponytail: no recovery screen; a store that can't open is a bug to fix, never a reason to start empty over the data.
    private let container: ModelContainer
    private let reminders: Reminders
    private let responder: NotificationResponder

    init() {
        Launch.resetDemoPreferences()
        let container = Self.makeContainer()
        let reminders = Reminders(center: Launch.isDemo ? SilentReminderCenter() : SystemReminderCenter())
        self.container = container
        self.reminders = reminders
        responder = NotificationResponder { action, keys in
            NotificationActions.apply(action, to: keys, in: container.mainContext, snoozeMinutes: reminders.snoozeMinutes)
            await BackgroundReplan.run(container: container, reminders: reminders)
        }
        UNUserNotificationCenter.current().delegate = responder
    }

    var body: some Scene {
        WindowGroup {
            RootView(reminders: reminders)
        }
        .modelContainer(container)
        // iOS wakes the app now and then to roll the 64 notifications forward.
        .backgroundTask(.appRefresh(BackgroundReplan.identifier)) { [container, reminders] in
            BackgroundReplan.scheduleNext()
            await BackgroundReplan.run(container: container, reminders: reminders)
        }
    }

    private static func makeContainer() -> ModelContainer {
        // fastlane snapshot shows the made-up family, never the user's own.
        if Launch.isSnapshot { return .sample(now: Launch.snapshotNow) }
        // UI flow tests start from an empty store of their own.
        if Launch.isEmptyStore, let container = try? ModelContainer.meds(inMemory: true) { return container }
        do {
            return try ModelContainer.meds()
        } catch {
            fatalError("Meds store failed to open: \(error)")
        }
    }
}
