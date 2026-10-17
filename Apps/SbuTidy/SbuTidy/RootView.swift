import SbuKit
import SwiftData
import SwiftUI
import WidgetKit

/// The app inside the standard Sbu shell. "Now" moves on when the app comes back and at midnight;
/// reminders and the widget follow every save.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @State private var clock = Clock()
    @State private var reminders = Reminders(center: Launch.isDemo ? SilentReminderCenter() : SystemReminderCenter())

    var body: some View {
        SbuAppShell("Sbu Tidy", slug: "tidy", accent: .tidy, appIcon: Image(.appIconArtwork)) {
            TodayView()
        } settings: {
            ReminderSection(reminders: reminders)
        }
        .environment(clock)
        .onChange(of: scenePhase, initial: true) {
            guard scenePhase == .active else { return }
            clock.refresh()
            reschedule()
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            storeChanged()
        }
        .onChange(of: reminders.isOn) {
            reschedule()
        }
        .onChange(of: reminders.minutesAfterMidnight) {
            reschedule()
        }
        .task {
            await clock.runMidnights()
        }
    }

    private func storeChanged() {
        // Made-up data never reaches the Home Screen.
        if !Launch.isDemo { WidgetCenter.shared.reloadAllTimelines() }
        reschedule()
    }

    private func reschedule() {
        let chores = ((try? modelContext.fetch(FetchDescriptor<Chore>())) ?? []).map(\.snapshot)
        Task { await reminders.reschedule(chores) }
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
