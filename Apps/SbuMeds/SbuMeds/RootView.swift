import SbuKit
import SwiftData
import SwiftUI
import WidgetKit

/// The app inside the standard Sbu shell. When the app comes back, the days that ended are
/// closed into the history and "now" moves on; reminders and the widget follow every save.
struct RootView: View {
    let reminders: Reminders

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @State private var clock = Clock(fixed: Launch.isSnapshot ? Launch.snapshotNow : nil)

    var body: some View {
        SbuAppShell("Sbu Meds", slug: "meds", accent: .meds, appIcon: Image(.appIconArtwork)) {
            TodayView()
        } settings: {
            ReminderSection(reminders: reminders)
            CareNoteSection()
        }
        .environment(clock)
        .environment(reminders)
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .background, !Launch.isDemo {
                BackgroundReplan.scheduleNext()
            }
            guard scenePhase == .active else { return }
            clock.refresh()
            closePastDays()
            reschedule()
        }
        .onChange(of: Day(clock.now, calendar: calendar)) {
            closePastDays()
            reschedule()
        }
        // The clock set by hand, a new time zone: doses stay at their local time, so plan again.
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            timeChanged()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
            timeChanged()
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            storeChanged()
        }
        .onChange(of: reminders.isOn) {
            reschedule()
        }
        .onChange(of: reminders.repeatMinutes) {
            reschedule()
        }
        .onChange(of: reminders.snoozeMinutes) {
            reschedule()
        }
        .task {
            await clock.run()
        }
    }

    private func timeChanged() {
        clock.refresh()
        closePastDays()
        reschedule()
    }

    private func closePastDays() {
        Cabinet.ensurePerson(in: modelContext)
        Cabinet.closePastDays(in: modelContext, now: clock.now, calendar: calendar)
        try? modelContext.save()
    }

    private func storeChanged() {
        // Made-up data never reaches the Home Screen.
        if !Launch.isDemo { WidgetCenter.shared.reloadAllTimelines() }
        reschedule()
    }

    private func reschedule() {
        let medicines = ((try? modelContext.fetch(FetchDescriptor<Medicine>())) ?? []).map(\.snapshot)
        Task { await reminders.reschedule(medicines) }
    }
}

#Preview("Light") {
    RootView(reminders: Reminders(center: SilentReminderCenter()))
        .modelContainer(.preview)
}

#Preview("Dark") {
    RootView(reminders: Reminders(center: SilentReminderCenter()))
        .modelContainer(.preview)
        .preferredColorScheme(.dark)
}
