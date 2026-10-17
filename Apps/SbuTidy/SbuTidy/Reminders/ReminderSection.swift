import SbuKit
import SwiftUI

/// Settings → reminders: on or off, at what time, whether iOS lets them through, and a test.
struct ReminderSection: View {
    @Bindable var reminders: Reminders

    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            Toggle("Promemoria", isOn: $reminders.isOn)
                .accessibilityIdentifier("remindersToggle")
            if reminders.isOn {
                DatePicker("Ora", selection: time, displayedComponents: .hourAndMinute)
                switch reminders.access {
                case .denied:
                    Label("Notifiche spente per Sbu Tidy", systemImage: "exclamationmark.triangle")
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

    private var time: Binding<Date> {
        Binding { reminders.time() } set: { reminders.setTime($0) }
    }

    private var footer: LocalizedStringKey {
        if reminders.isOn, reminders.access == .denied {
            return "Senza notifiche nessuna attività ti avvisa. Attivale nelle Impostazioni dell'iPhone."
        }
        return "Una notifica solo nei giorni in cui un'attività diventa da fare. Se non c'è niente, nessuna notifica."
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
    }
}

#Preview("Light") {
    Form {
        ReminderSection(reminders: Reminders(defaults: UserDefaults(suiteName: "preview") ?? .standard, center: SilentReminderCenter()))
    }
    .environment(\.sbuAccent, .tidy)
}

#Preview("Dark") {
    Form {
        ReminderSection(reminders: Reminders(defaults: UserDefaults(suiteName: "preview") ?? .standard, center: SilentReminderCenter()))
    }
    .environment(\.sbuAccent, .tidy)
    .preferredColorScheme(.dark)
}
