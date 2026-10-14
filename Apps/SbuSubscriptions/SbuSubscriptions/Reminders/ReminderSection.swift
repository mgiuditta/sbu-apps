import SbuKit
import SwiftUI

/// Settings → when reminders arrive, whether iOS lets them through, and a test.
struct ReminderSection: View {
    let reminders: Reminders

    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            DatePicker("Ora dei promemoria", selection: time, displayedComponents: .hourAndMinute)
            switch reminders.access {
            case .denied:
                Label("Notifiche spente per Sbu Subscriptions", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.warning)
                Button("Apri Impostazioni", action: openSettings)
            case .allowed:
                Button("Invia un promemoria di prova", action: reminders.sendTest)
            case .notDetermined:
                EmptyView()
            }
        } header: {
            Text("Promemoria")
        } footer: {
            Text(footer)
        }
        .task { await reminders.refreshAccess() }
    }

    private var time: Binding<Date> {
        Binding { reminders.time() } set: { reminders.setTime($0) }
    }

    private var footer: LocalizedStringKey {
        switch reminders.access {
        case .denied: "Senza notifiche nessun rinnovo ti avvisa. Attivale nelle Impostazioni dell'iPhone."
        case .allowed: "Arriva tra pochi secondi, anche con l'app aperta."
        case .notDetermined: "Quanti giorni prima lo scegli per ogni abbonamento."
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
    }
}
