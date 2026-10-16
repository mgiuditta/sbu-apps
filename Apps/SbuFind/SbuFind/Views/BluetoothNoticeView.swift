import SbuKit
import SwiftUI

/// Why the scan is not running, and the one thing that fixes it.
struct BluetoothNoticeView: View {
    @Environment(\.openURL) private var openURL

    let notice: BluetoothNotice

    var body: some View {
        NoticeView(title: notice.title, message: notice.message, systemImage: notice.systemImage) {
            if notice.opensSettings {
                SbuButton("Apri Impostazioni", action: openSettings)
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    BluetoothNotice(state: .denied).map(BluetoothNoticeView.init)
}

#Preview("Dark") {
    BluetoothNotice(state: .poweredOff).map(BluetoothNoticeView.init)
        .preferredColorScheme(.dark)
}
