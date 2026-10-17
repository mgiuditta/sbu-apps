import SbuKit
import SwiftData
import SwiftUI

/// The app inside the standard Sbu shell. Reminder notifications are planned again after every
/// save and whenever the app comes back.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var units = UnitSettings()
    @State private var notifications = ReminderNotifications(center: Self.isDemo ? SilentReminderCenter() : SystemReminderCenter())

    /// Screenshots and UI tests run on made-up data and must never touch the device's notifications.
    private static var isDemo: Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "FASTLANE_SNAPSHOT") || defaults.bool(forKey: "SBU_EMPTY_STORE") || defaults.bool(forKey: "SBU_SAMPLE_STORE")
    }

    var body: some View {
        SbuAppShell("Sbu Fuel", slug: "fuel", accent: .fuel, appIcon: Image(.appIconArtwork)) {
            MainView(units: units, notifications: notifications)
        } settings: {
            UnitsSection(units: units)
            DataSection(units: units)
        }
        .onChange(of: scenePhase, initial: true) {
            guard scenePhase == .active else { return }
            reschedule()
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            reschedule()
        }
        // Allowed in the prompt after saving a reminder: the plan made a moment before had nothing to send.
        .onChange(of: notifications.access) {
            reschedule()
        }
    }

    private func reschedule() {
        let vehicles = (try? modelContext.fetch(FetchDescriptor<Vehicle>())) ?? []
        let inputs = vehicles.flatMap { $0.reminderInputs() }
        Task { await notifications.reschedule(inputs) }
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
