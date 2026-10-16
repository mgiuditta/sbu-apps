import SbuKit
import SwiftUI

/// Settings → reminders: on or off, how often an unmarked one comes back, how long "Rimanda"
/// waits, whether iOS lets them through, and a test.
struct ReminderSection: View {
    @Bindable var reminders: Reminders

    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            Toggle("Promemoria", isOn: $reminders.isOn)
                .accessibilityIdentifier("remindersToggle")
            if reminders.isOn {
                Picker("Ripeti se non la segni", selection: $reminders.repeatMinutes) {
                    ForEach(Reminders.repeatChoices, id: \.self) { minutes in
                        Text(minutes == 0 ? "Mai" : "Ogni \(minutes) min").tag(minutes)
                    }
                }
                .accessibilityIdentifier("repeatMinutes")
                Picker("Rimanda di", selection: $reminders.snoozeMinutes) {
                    ForEach(Reminders.snoozeChoices, id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .accessibilityIdentifier("snoozeMinutes")
                switch reminders.access {
                case .denied:
                    Label("Notifiche spente per Sbu Meds", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(SbuTheme.warning)
                    Button("Apri Impostazioni", action: openSettings)
                case .allowed:
                    Button("Invia un promemoria di prova", action: reminders.sendTest)
                case .notDetermined:
                    EmptyView()
                }
            }
        } header: {
            Text("Promemoria")
        } footer: {
            Text(footer)
        }
        .listRowBackground(SbuTheme.surfaceRaised)
        .task { await reminders.refreshAccess() }
    }

    private var footer: LocalizedStringKey {
        if reminders.isOn, reminders.access == .denied {
            return "Senza notifiche nessuna dose ti avvisa. Attivale nelle Impostazioni dell'iPhone."
        }
        if reminders.isOn, reminders.repeatMinutes > 0 {
            return "Una notifica per persona e orario, con Presa, Saltata e Rimanda. Se non la segni torna fino a \(ReminderPlan.repeats) volte, e sparisce appena la segni."
        }
        return "Una notifica per persona e orario, con Presa, Saltata e Rimanda. Locali, programmate sull'iPhone."
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
    }
}

#Preview("Light") {
    Form {
        ReminderSection(reminders: Reminders(defaults: UserDefaults(suiteName: "preview") ?? .standard, center: SilentReminderCenter()))
    }
    .tint(SbuTheme.accentMeds)
}

#Preview("Dark") {
    Form {
        ReminderSection(reminders: Reminders(defaults: UserDefaults(suiteName: "preview") ?? .standard, center: SilentReminderCenter()))
    }
    .tint(SbuTheme.accentMeds)
    .preferredColorScheme(.dark)
}
