import SbuKit
import SwiftUI
import UIKit

/// A warning under an alarm: the symbol and the words, never the color alone. When a permission
/// is off, Apri Impostazioni goes straight to the switch.
struct AlarmWarningRow: View {
    let warning: AlarmWarning

    @Environment(\.openURL) private var openURL

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(warning.message)
                    .foregroundStyle(SbuTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let settings {
                    Button("Apri Impostazioni") { openURL(settings) }
                        .fontWeight(.semibold)
                        .frame(minHeight: SbuTheme.controlRoundSm)
                        .contentShape(.rect)
                }
            }
        } icon: {
            Image(systemName: "exclamationmark.triangle")
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.warning)
        }
        .font(SbuTheme.subheadline)
    }

    /// The app's page in Impostazioni: its notifications for the notification backup.
    private var settings: URL? {
        switch warning {
        case .notificationsDenied: URL(string: UIApplication.openNotificationSettingsURLString)
        case .systemAlarmsDenied: URL(string: UIApplication.openSettingsURLString)
        case .soundStopsBefore: nil
        }
    }
}

#Preview("Light") {
    List { AlarmWarningRow(warning: .notificationsDenied) }
        .tint(SbuTheme.accentNoise)
}

#Preview("Dark") {
    List { AlarmWarningRow(warning: .soundStopsBefore(.notifications)) }
        .tint(SbuTheme.accentNoise)
        .preferredColorScheme(.dark)
}
