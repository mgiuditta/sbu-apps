import SbuKit
import SwiftUI

/// The remote: Home and power on top, the navigation area, then the other keys.
/// On `surface` like every Sbu screen; no figure and no full stop (#349).
struct RemoteView: View {
    let session: RemoteSession
    let tvName: String

    @AppStorage("navigationMode") private var mode = NavigationMode.dPad
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver

    /// VoiceOver always gets the labelled arrows: the touchpad is a gesture surface.
    private var shownMode: NavigationMode { voiceOver ? .dPad : mode }

    var body: some View {
        ScrollView {
            VStack(spacing: SbuTheme.space5) {
                ConnectionStatusView(tvName: tvName, status: session.status, onRetry: retry)
                HStack(spacing: SbuTheme.space4) {
                    RemoteKeyButton(key: .home, session: session, side: SbuTheme.controlRoundSm)
                    Picker("Navigazione", selection: $mode) {
                        Label("Frecce", systemImage: NavigationMode.dPad.systemImage).tag(NavigationMode.dPad)
                        Label("Touchpad", systemImage: NavigationMode.touchpad.systemImage).tag(NavigationMode.touchpad)
                    }
                    .pickerStyle(.segmented)
                    .labelStyle(.iconOnly)
                    .opacity(voiceOver ? 0 : 1)
                    .accessibilityHidden(voiceOver)
                    RemoteKeyButton(key: .power, session: session, side: SbuTheme.controlRoundSm)
                }
                Group {
                    switch shownMode {
                    case .dPad: DPadView(session: session)
                    case .touchpad: TouchpadView(session: session)
                    }
                }
                .frame(height: SbuTheme.controlRoundLg * 3)
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
