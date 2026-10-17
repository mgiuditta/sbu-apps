import SbuKit
import SwiftUI

/// The remote: the title with the TV in the cartiglio, Home and power, the navigation area, then
/// the other keys. On plain paper: the keys and the touchpad are the instrument, so no grid under
/// them. No figure and no full stop (#349).
struct RemoteView: View {
    let session: RemoteSession
    let tvName: String
    var pinnedApps: [TVShortcut] = []
    var onInputs: ([TVShortcut]) -> Void = { _ in }
    var onAddTV: () -> Void = {}

    @AppStorage("navigationMode") private var mode = NavigationMode.dPad
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// VoiceOver always gets the labelled arrows: the touchpad is a gesture surface.
    private var shownMode: NavigationMode { voiceOver ? .dPad : mode }

    /// "Sbu · Telecomando · Soggiorno": the TV the keys go to.
    private var cartiglio: String {
        ["Sbu", String(localized: "Telecomando"), tvName].joined(separator: " · ")
    }

    private var statusLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space2))
            : AnyLayout(HStackLayout(spacing: SbuTheme.space4))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: SbuTheme.space4) {
                SbuScreenTitle("Telecomando", cartiglio: cartiglio)
                // The bar stays empty on the tool screen, so the TV switch sits by its status.
                // Stacked at the accessibility sizes, so the TV's name never squeezes the status.
                statusLayout {
                    ConnectionStatusView(tvName: tvName, status: session.status, onRetry: retry)
                    Spacer(minLength: 0)
                    TVPickerMenu(session: session, onAdd: onAddTV)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
                .frame(height: SbuTheme.controlRound * 4)
                KeyGridView(session: session)
                VolumeChannelView(session: session, onInputs: onInputs)
                if !pinnedApps.isEmpty {
                    ShortcutRowView(apps: pinnedApps, session: session)
                }
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.top, SbuTheme.space4)
            .padding(.bottom, SbuTheme.space4)
        }
        .scrollBounceBehavior(.basedOnSize)
        .sbuPaper(grid: false)
    }

    private func retry() {
        Task { await session.connect() }
    }
}

#Preview("Light") {
    NavigationStack {
        RemoteView(session: .preview, tvName: "Soggiorno")
    }
    .tint(SbuTheme.ink)
}

#Preview("Dark") {
    NavigationStack {
        RemoteView(session: .preview, tvName: "Soggiorno")
    }
    .tint(SbuTheme.ink)
    .preferredColorScheme(.dark)
}
