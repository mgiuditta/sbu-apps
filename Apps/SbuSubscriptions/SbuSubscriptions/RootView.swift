import SbuKit
import SwiftData
import SwiftUI

/// The app inside the standard Sbu shell. Reminders are planned again after every save and whenever it comes back.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var currency = CurrencySettings()
    @State private var reminders = Reminders(center: Self.isDemo ? SilentReminderCenter() : SystemReminderCenter())

    /// Screenshots and UI tests run on made-up data and must never touch the device's notifications.
    private static var isDemo: Bool {
        UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || UserDefaults.standard.bool(forKey: "SBU_EMPTY_STORE")
    }

    var body: some View {
        SbuAppShell("Sbu Subscriptions", slug: "subscriptions", accent: SbuTheme.accentSubscriptions, appIcon: Image(.appIconArtwork)) {
            MainView(currency: currency)
        } settings: {
            TotalSection()
            ReminderSection(reminders: reminders)
            CurrencySection(settings: currency)
            OrganizeSection()
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active { reschedule() }
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            reschedule()
        }
        .onChange(of: reminders.minutesAfterMidnight) {
            reschedule()
        }
    }

    private func reschedule() {
        let sources = ((try? modelContext.fetch(FetchDescriptor<Subscription>())) ?? []).map(\.reminderSource)
        Task { await reminders.reschedule(sources) }
    }
}

#Preview("Light") {
    RootView()
        .modelContainer(.preview)
}

#Preview("Dark") {
    RootView()
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
