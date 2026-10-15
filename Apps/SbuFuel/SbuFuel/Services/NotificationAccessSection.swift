import SbuKit
import SwiftUI

/// When reminders exist but iOS lets no notification through: why, and what to do.
struct NotificationAccessSection: View {
    let access: NotificationAccess
    let ask: () -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            // Not a Label: in a list row the audit read its title as clipped, its frame starting under the icon.
            HStack(spacing: SbuTheme.space3) {
                Image(systemName: "bell.slash")
                    .fontWeight(.medium)
                    .accessibilityHidden(true)
                Text("Notifiche spente per Sbu Fuel")
            }
            .foregroundStyle(SbuTheme.warning)
            if access == .denied {
                Button("Apri Impostazioni", action: openSettings)
                    .accessibilityIdentifier("openSettings")
            } else {
                Button("Attiva le notifiche", action: ask)
                    .accessibilityIdentifier("allowNotifications")
            }
        } footer: {
            Text("I promemoria restano qui, ma senza notifiche nessuno ti avvisa.")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
    }
}

#Preview("Light") {
    List {
        NotificationAccessSection(access: .denied, ask: {})
    }
}

#Preview("Dark") {
    List {
        NotificationAccessSection(access: .notDetermined, ask: {})
    }
    .preferredColorScheme(.dark)
}
