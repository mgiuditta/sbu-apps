import SbuKit
import SwiftData
import SwiftUI

/// The app inside the standard Sbu shell. When the app comes back, the days that ended are
/// closed into the history and "now" moves on.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @State private var clock = Clock(fixed: Launch.isSnapshot ? Launch.snapshotNow : nil)

    var body: some View {
        SbuAppShell("Sbu Meds", slug: "meds", accent: SbuTheme.accentMeds, appIcon: Image(.appIconArtwork)) {
            TodayView()
        } settings: {
            EmptyView()
        }
        .environment(clock)
        .onChange(of: scenePhase, initial: true) {
            guard scenePhase == .active else { return }
            clock.refresh()
            closePastDays()
        }
        .onChange(of: Day(clock.now, calendar: calendar)) {
            closePastDays()
        }
        .task {
            await clock.run()
        }
    }

    private func closePastDays() {
        Cabinet.ensurePerson(in: modelContext)
        Cabinet.closePastDays(in: modelContext, now: clock.now, calendar: calendar)
        try? modelContext.save()
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
