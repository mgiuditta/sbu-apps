import SbuKit
import SwiftUI

/// The app inside the standard Sbu shell. Phase alerts are planned again each time it comes back.
struct RootView: View {
    @State private var model = MoonModel()
    @State private var places = PlaceModel()
    @State private var alerts = PhaseAlerts()

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        SbuAppShell("Sbu Moon", slug: "moon", accent: .moon, appIcon: Image(.appIconArtwork)) {
            MainView(model: model, places: places)
        } settings: {
            PhaseAlertsSection(alerts: alerts)
            CalculationSection()
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active {
                Task { await alerts.reschedule() }
            }
        }
    }
}

#Preview("Light") {
    RootView()
}

#Preview("Dark") {
    RootView()
        .preferredColorScheme(.dark)
}
