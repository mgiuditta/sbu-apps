import SbuKit
import SwiftUI

/// The connection state in a word and an SF Symbol, with a way to try again when it failed.
struct ConnectionStatusView: View {
    let tvName: String
    let status: ConnectionStatus
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            Label {
                Text(status.title)
            } icon: {
                Image(systemName: status.systemImage)
                    .fontWeight(.medium)
            }
            .font(SbuTheme.subheadline)
            .foregroundStyle(SbuTheme.inkMuted)
            .accessibilityLabel(Text("\(tvName): \(Text(status.title))"))

            if status == .unreachable || status == .notPaired {
                Button("Riprova", action: onRetry)
                    .font(SbuTheme.subheadline)
            }
        }
        .frame(minHeight: SbuTheme.controlRoundSm)
    }
}

#Preview("Light") {
    VStack {
        ConnectionStatusView(tvName: "Soggiorno", status: .connected) {}
        ConnectionStatusView(tvName: "Soggiorno", status: .unreachable) {}
    }
    .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    VStack {
        ConnectionStatusView(tvName: "Soggiorno", status: .connecting) {}
        ConnectionStatusView(tvName: "Soggiorno", status: .notPaired) {}
    }
    .tint(SbuTheme.accentRemote)
    .preferredColorScheme(.dark)
}
