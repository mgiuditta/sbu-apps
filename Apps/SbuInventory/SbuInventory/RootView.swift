import SbuKit
import SwiftData
import SwiftUI

/// The app inside the standard Sbu shell. The "Da ricomprare" reminder is planned again after every
/// save and whenever the app comes back.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @State private var reminders = LowStockReminders(center: Self.isDemo ? SilentReminderCenter() : SystemReminderCenter())

    /// Screenshots and UI tests run on made-up data and never touch the iPhone's notifications.
    private static var isDemo: Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_EMPTY_STORE") || defaults.bool(forKey: "SBU_SAMPLE_STORE")
            || ProcessInfo.processInfo.environment["SBU_STORE_FILE"] != nil
    }

    var body: some View {
        SbuAppShell("Sbu Inventory", slug: "inventory", accent: SbuTheme.accentInventory, appIcon: Image(.appIconArtwork)) {
            InventoryHome()
        } settings: {
            DataSection()
            FieldsSection()
            ReminderSection(reminders: reminders)
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active { reschedule() }
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            reschedule()
        }
        .onChange(of: reminders.isOn) { reschedule() }
        .onChange(of: reminders.minutesAfterMidnight) { reschedule() }
    }

    private func reschedule() {
        let low = ((try? context.fetch(FetchDescriptor<Item>())) ?? []).filter(\.isLow).map(\.name)
        Task { await reminders.reschedule(lowItems: low) }
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
