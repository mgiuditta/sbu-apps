import SbuKit
import SwiftUI

/// A warning under an alarm: the symbol and the words, never the color alone.
struct AlarmWarningRow: View {
    let warning: AlarmWarning

    var body: some View {
        Label {
            Text(warning.message)
                .foregroundStyle(SbuTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "exclamationmark.triangle")
                .fontWeight(.medium)
                .foregroundStyle(SbuTheme.warning)
        }
        .font(SbuTheme.subheadline)
    }
}

#Preview("Light") {
    List { AlarmWarningRow(warning: .notificationsDenied) }
}

#Preview("Dark") {
    List { AlarmWarningRow(warning: .soundStopsBefore(.notifications)) }
        .preferredColorScheme(.dark)
}
