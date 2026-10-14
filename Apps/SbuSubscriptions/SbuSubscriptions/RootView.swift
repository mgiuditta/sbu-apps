import CoreData
import SbuKit
import SwiftData
import SwiftUI
import WidgetKit

/// The app inside the standard Sbu shell. Reminders are planned again after every save and whenever it comes back.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var currency = CurrencySettings()
    @State private var reminders = Reminders(center: Self.isDemo ? SilentReminderCenter() : SystemReminderCenter())

    /// Screenshots and UI tests run on made-up data and must never touch the device's notifications.
    /// The device notification test opts back in with SBU_REAL_NOTIFICATIONS, on its own empty store.
    private static var isDemo: Bool {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "SBU_REAL_NOTIFICATIONS") { return false }
        return defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_EMPTY_STORE")
    }

    var body: some View {
        SbuAppShell("Sbu Subscriptions", slug: "subscriptions", accent: SbuTheme.accentSubscriptions, appIcon: Image(.appIconArtwork),
                    dataLocation: Self.syncsWithICloud ? .yourDevices : .thisDevice) {
            MainView(currency: currency)
        } settings: {
            TotalSection()
            ReminderSection(reminders: reminders)
            CurrencySection(settings: currency)
            OrganizeSection()
            DataSection(currency: currency)
            LegacyImportSection()
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active { reschedule() }
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            reschedule()
        }
        // Changes brought in from your other devices through iCloud.
        .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange).receive(on: RunLoop.main)) { _ in
            reschedule()
        }
        .onChange(of: reminders.minutesAfterMidnight) {
            reschedule()
        }
    }

    /// What the store was opened with: the promise in Settings says where the data is right now.
    private static let syncsWithICloud = UserDefaults.appGroup.bool(forKey: ModelContainer.iCloudSyncKey)

    private func reschedule() {
        try? CategorySeeder.mergeDuplicates(modelContext)
        let subscriptions = (try? modelContext.fetch(FetchDescriptor<Subscription>())) ?? []
        PriceSettler.settle(subscriptions)
        let sources = subscriptions.map(\.reminderSource)
        WidgetCenter.shared.reloadAllTimelines()
        SpotlightIndex.update(subscriptions)
        Task { await reminders.reschedule(sources) }
    }
}

#Preview("Light") {
    RootView()
        .modelContainer(.preview)
        .environment(AppRouter())
}

#Preview("Dark") {
    RootView()
        .modelContainer(.preview)
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
