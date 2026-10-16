import SwiftData
import SwiftUI
import UserNotifications
import WidgetKit

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
            let context = container.mainContext
            NotificationActions.apply(action, to: keys, in: context, snoozeMinutes: reminders.snoozeMinutes)
            try? context.save()
            WidgetCenter.shared.reloadAllTimelines()
            let medicines = ((try? context.fetch(FetchDescriptor<Medicine>())) ?? []).map(\.snapshot)
            await reminders.reschedule(medicines)
        }
        UNUserNotificationCenter.current().delegate = responder
    }

    var body: some Scene {
        WindowGroup {
            RootView(reminders: reminders)
        }
        .modelContainer(container)
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
