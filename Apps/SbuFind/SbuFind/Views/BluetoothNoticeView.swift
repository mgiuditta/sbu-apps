import SbuKit
import SwiftUI

/// Why the scan is not running, and the one thing that fixes it.
///
/// Laid out like `ContentUnavailableView`, but in a scroll view that is at least as tall as the
/// screen: centred at normal sizes, scrolling at the largest ones instead of clipping.
struct BluetoothNoticeView: View {
    @Environment(\.openURL) private var openURL

    let notice: BluetoothNotice

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SbuTheme.space4) {
                    Image(systemName: notice.systemImage)
                        .font(SbuTheme.largeTitle)
                        .fontWeight(.medium)
                        .imageScale(.large)
                        .foregroundStyle(SbuTheme.inkMuted)
                        .accessibilityHidden(true)

                    VStack(spacing: SbuTheme.space2) {
                        Text(notice.title)
                            .font(SbuTheme.title2)
                            .foregroundStyle(SbuTheme.ink)
                            .accessibilityAddTraits(.isHeader)

                        Text(notice.message)
                            .font(SbuTheme.body)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    .multilineTextAlignment(.center)

                    if notice.opensSettings {
                        SbuButton("Apri Impostazioni", action: openSettings)
                            .padding(.top, SbuTheme.space2)
                    }
                }
                .padding(SbuTheme.space8)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
        .background(SbuTheme.surface)
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
