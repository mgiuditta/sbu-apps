import SbuKit
import SwiftUI

/// Settings → the "Da ricomprare" reminder: off by default; when on, the time it arrives.
struct ReminderSection: View {
    let reminders: LowStockReminders

    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            Toggle("Avvisami", isOn: isOn)
                .accessibilityIdentifier("reminderToggle")
            if reminders.isOn {
                DatePicker("Ora", selection: time, displayedComponents: .hourAndMinute)
            }
            if reminders.isDenied {
                Label("Notifiche spente per Sbu Inventory", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.warning)
                Button("Apri Impostazioni", action: openSettings)
            }
        } header: {
            Text("Da ricomprare")
        } footer: {
            Text(reminders.isDenied
                 ? "Senza notifiche nessun avviso arriva. Attivale nelle Impostazioni dell'iPhone."
                 : "Una notifica all'ora che scegli con gli oggetti arrivati alla quantità minima, che imposti in ogni oggetto.")
        }
        .task { await reminders.refreshAccess() }
    }

    private var isOn: Binding<Bool> {
        Binding { reminders.isOn } set: { on in Task { await reminders.setOn(on) } }
    }

    private var time: Binding<Date> {
        Binding {
            Calendar.current.startOfDay(for: .now).addingTimeInterval(TimeInterval(reminders.minutesAfterMidnight * 60))
        } set: { date in
            let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
            reminders.setTime((parts.hour ?? 0) * 60 + (parts.minute ?? 0))
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
    }
}

#Preview("Light") {
    Form {
        ReminderSection(reminders: LowStockReminders(center: SilentReminderCenter()))
    }
}

#Preview("Dark") {
    Form {
        ReminderSection(reminders: LowStockReminders(center: SilentReminderCenter()))
    }
    .preferredColorScheme(.dark)
}
