import SbuKit
import SwiftUI

/// The remote: Home and power on top, the navigation area, then the other keys.
/// On `surface` like every Sbu screen; no figure and no full stop (#349).
struct RemoteView: View {
    let session: RemoteSession
    let tvName: String

    var body: some View {
        ScrollView {
            VStack(spacing: SbuTheme.space5) {
                ConnectionStatusView(tvName: tvName, status: session.status, onRetry: retry)
                HStack {
                    RemoteKeyButton(key: .home, session: session, side: SbuTheme.controlRoundSm)
                    Spacer()
                    RemoteKeyButton(key: .power, session: session, side: SbuTheme.controlRoundSm)
                }
                DPadView(session: session)
                HStack {
                    RemoteKeyButton(key: .back, session: session)
                    Spacer()
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.bottom, SbuTheme.space4)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func retry() {
        Task { await session.connect() }
    }
}

#Preview("Light") {
    NavigationStack {
        RemoteView(session: .preview, tvName: "Soggiorno")
            .background(SbuTheme.surface)
    }
    .tint(SbuTheme.accentRemote)
}

#Preview("Dark") {
    NavigationStack {
        RemoteView(session: .preview, tvName: "Soggiorno")
            .background(SbuTheme.surface)
    }
    .tint(SbuTheme.accentRemote)
    .preferredColorScheme(.dark)
}
