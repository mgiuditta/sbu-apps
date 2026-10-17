import SbuKit
import SwiftUI

/// Settings section to choose which principal phases send an alert, and at what time.
/// Turning the first one on asks for notification permission; a refusal is explained here.
/// Each alert turned on, once iOS will deliver it, closes with "Impostato" under the toggles.
struct PhaseAlertsSection: View {
    @Bindable var alerts: PhaseAlerts

    @Environment(\.openURL) private var openURL
    @State private var isShowingClosure = false

    var body: some View {
        Section {
            ForEach(PrincipalPhase.allCases, id: \.self) { phase in
                Toggle(phase.phase.name, isOn: $alerts.selection[phase])
            }

            // The settings sheet covers the figure: the Closure shows here, where the alert was set.
            if isShowingClosure {
                PhaseAlertClosure(isShowing: $isShowingClosure)
            }

            if alerts.selection.isEmpty == false {
                DatePicker("Ora dell'avviso", selection: time, displayedComponents: .hourAndMinute)
            }

            if alerts.isBlocked {
                Button("Apri Impostazioni", action: openSettings)
            }
        } header: {
            Text("Avvisi di fase")
        } footer: {
            if alerts.isBlocked {
                Text("Le notifiche di Sbu Moon sono disattivate: gli avvisi non arrivano. Attivale nelle Impostazioni dell'iPhone.")
            } else {
                Text("Ti avvisa il giorno della fase, all'ora che scegli.")
            }
        }
        .onChange(of: alerts.selection) { previous, _ in
            Task {
                if await alerts.settingsChanged(from: previous) {
                    isShowingClosure = true
                }
            }
        }
        .onChange(of: alerts.minutesAfterMidnight) {
            Task { await alerts.settingsChanged() }
        }
        .task {
            await alerts.reschedule()
        }
    }

    /// The alert time for the picker, kept as minutes after midnight in the model.
    private var time: Binding<Date> {
        Binding(get: { alerts.time() }, set: { alerts.setTime($0) })
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    PhaseAlertsSectionPreview()
}

#Preview("Dark") {
    PhaseAlertsSectionPreview()
        .preferredColorScheme(.dark)
}

private struct PhaseAlertsSectionPreview: View {
    @State private var alerts = PhaseAlerts(defaults: UserDefaults(suiteName: "preview") ?? .standard)

    var body: some View {
        Form {
            PhaseAlertsSection(alerts: alerts)
        }
        .tint(SbuTheme.ink)
    }
}
