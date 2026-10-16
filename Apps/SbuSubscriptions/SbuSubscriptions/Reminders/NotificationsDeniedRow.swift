import SbuKit
import SwiftUI

/// In the add and edit forms, under the reminder: notifications are off for the app, where to turn
/// them back on, and a button that goes straight there.
struct NotificationsDeniedRow: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Label("Notifiche disattivate", systemImage: "exclamationmark.triangle")
                .symbolRenderingMode(.monochrome)
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.warning)
            Text("Vai in Impostazioni > Notifiche > Sbu Subscriptions > Consenti notifiche.")
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .accessibilityElement(children: .combine)
        Button("Apri Impostazioni", action: openSettings)
            .accessibilityIdentifier("openNotificationSettings")
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
    }
}

#Preview("Light") {
    Form { NotificationsDeniedRow() }
}

#Preview("Dark") {
    Form { NotificationsDeniedRow() }
        .preferredColorScheme(.dark)
}
