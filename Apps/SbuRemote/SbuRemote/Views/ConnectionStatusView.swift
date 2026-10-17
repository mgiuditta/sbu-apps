import SbuKit
import SwiftUI

/// The connection state in a word and the row mark, filled once connected, with a way to try
/// again when it failed.
struct ConnectionStatusView: View {
    let tvName: String
    let status: ConnectionStatus
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            HStack(spacing: SbuTheme.space2) {
                SbuRowMark(filled: status == .connected)
                Text(status.title)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            .accessibilityElement(children: .combine)
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
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    VStack {
        ConnectionStatusView(tvName: "Soggiorno", status: .connecting) {}
        ConnectionStatusView(tvName: "Soggiorno", status: .notPaired) {}
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
